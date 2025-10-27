class ProjectsController < ApplicationController
  before_action :set_project, only: [:show, :edit, :update, :destroy, :optimize, :download_results, :mark_cut_completed, :unmark_cut_completed]

  def index
    @projects = Project.recent.all
    @inventory_sheets = InventorySheet.available
  end

  def new
    @project = Project.new
    # Don't build empty records - let user add them via JavaScript
  end

  def create
    @project = Project.new(project_params)

    # Handle file upload if present
    if @project.input_file.attached?
      # Save project first to persist the file
      if @project.save
        service = OptimizerService.new(@project)
        if service.parse_uploaded_file
          @project.update(status: 'draft')
          redirect_to @project, notice: 'Projeto criado com sucesso. Configure as quantidades e processe a otimização.'
        else
          @project.destroy
          @project = Project.new(project_params)
          flash.now[:alert] = "Erro ao processar arquivo: #{service.errors.join(', ')}"
          render :new, status: :unprocessable_entity
        end
      else
        render :new, status: :unprocessable_entity
      end
    else
      # Manual input - just save
      if @project.save
        redirect_to @project, notice: 'Projeto criado com sucesso.'
      else
        render :new, status: :unprocessable_entity
      end
    end
  end

  def show
    @result_files = @project.result_files.attachments if @project.optimized?
  end

  def edit
  end

  def update
    if @project.update(project_params)
      # If sheets or pieces changed, reset status to draft
      @project.update(status: 'draft') if @project.optimized?
      
      redirect_to @project, notice: 'Projeto atualizado com sucesso.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @project.destroy
    redirect_to projects_url, notice: 'Projeto deletado com sucesso.'
  end

  def optimize
    unless @project.can_optimize?
      redirect_to @project, alert: 'Projeto não pode ser otimizado. Verifique se há chapas e peças configuradas.'
      return
    end

    @project.update!(status: 'pending')
    OptimizationJob.perform_later(@project.id)
    
    redirect_to @project, notice: 'Otimização iniciada. Aguarde o processamento...'
  end

  def download_results
    filename = params[:filename]
    
    # Find attachment by filename
    attachment = @project.result_files.attachments.find { |a| a.filename.to_s == filename }
    
    if attachment
      send_data attachment.download,
                filename: filename,
                type: attachment.content_type,
                disposition: 'inline'  # Open in browser instead of download
    else
      redirect_to @project, alert: "Arquivo '#{filename}' não encontrado."
    end
  end

  def mark_cut_completed
    if @project.cut_completed?
      redirect_to @project, alert: 'Este projeto já foi marcado como cortado.'
      return
    end

    if @project.mark_as_cut_completed!
      offcuts_created = InventorySheet.where(source_project_id: @project.id, is_offcut: true).count
      message = '✅ Projeto marcado como cortado. Inventário atualizado!'
      if offcuts_created > 0
        message += " ♻️ #{offcuts_created} sobra(s) adicionada(s) ao inventário."
      end
      redirect_to @project, notice: message
    else
      redirect_to @project, alert: 'Erro ao marcar projeto como cortado. Verifique se há chapas suficientes no inventário.'
    end
  end

  def unmark_cut_completed
    unless @project.cut_completed?
      redirect_to @project, alert: 'Este projeto não está marcado como cortado.'
      return
    end

    if @project.unmark_as_cut_completed!
      redirect_to @project, notice: '🔄 Status de corte removido. Chapas devolvidas ao inventário!'
    else
      redirect_to @project, alert: 'Erro ao remover status de cortado.'
    end
  end

  def interactive_layout
    @project = Project.find(params[:id])
    render :interactive_layout
  end

  def save_interactive_layout
    @project = Project.find(params[:id])
    
    begin
      layout_data = JSON.parse(request.body.read)
      
      # Create a new optimization result with the interactive layout
      pieces_data = layout_data['pieces'].map do |piece_data|
        {
          id: piece_data['id'],
          x: piece_data['x'].to_f,
          y: piece_data['y'].to_f,
          width: piece_data['width'].to_f,
          height: piece_data['height'].to_f,
          rotated: false
        }
      end
      
      # Calculate waste areas
      sheet_width = layout_data['sheet_width'].to_f
      sheet_height = layout_data['sheet_height'].to_f
      cutting_width = layout_data['cutting_width'].to_f
      
      # Find largest waste area (right side)
      rightmost_edge = pieces_data.map { |p| p[:x] + p[:width] }.max
      largest_waste_width = sheet_width - rightmost_edge
      largest_waste_height = sheet_height
      largest_waste_area = largest_waste_width * largest_waste_height
      
      # Create optimization data
      optimization_data = {
        sheets: [{
          id: @project.sheets.first&.id || 1,
          width: sheet_width,
          height: sheet_height,
          pieces: pieces_data,
          waste_areas: [{
            x: rightmost_edge,
            y: 0,
            width: largest_waste_width,
            height: largest_waste_height,
            area: largest_waste_area
          }]
        }],
        total_pieces: pieces_data.length,
        total_waste_area: largest_waste_area,
        utilization: ((pieces_data.sum { |p| p[:width] * p[:height] }) / (sheet_width * sheet_height) * 100).round(2)
      }
      
      # Update project with interactive layout
      @project.update!(
        optimization_data: optimization_data.to_json,
        status: 'optimized'
      )
      
      render json: { success: true, message: 'Layout interativo salvo com sucesso!' }
      
    rescue => e
      Rails.logger.error "Error saving interactive layout: #{e.message}"
      render json: { success: false, error: e.message }
    end
  end

  private

  def set_project
    @project = Project.find(params[:id])
  end

  def project_params
    params.require(:project).permit(
      :name,
      :description,
      :allow_rotation,
      :guillotine_mode,
      :cutting_width,
      :thickness,
      :use_inventory,
      :input_file,
      sheets_attributes: [:id, :label, :width, :height, :thickness, :quantity, :_destroy],
      pieces_attributes: [:id, :label, :width, :height, :thickness, :quantity, :_destroy]
    )
  end
end
