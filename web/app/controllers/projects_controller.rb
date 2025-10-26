class ProjectsController < ApplicationController
  before_action :set_project, only: [:show, :edit, :update, :destroy, :optimize, :download_results]

  def index
    @projects = Project.recent.all
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

  private

  def set_project
    @project = Project.find(params[:id])
  end

  def project_params
    params.require(:project).permit(
      :name,
      :description,
      :allow_rotation,
      :cutting_width,
      :input_file,
      sheets_attributes: [:id, :label, :width, :height, :thickness, :quantity, :_destroy],
      pieces_attributes: [:id, :label, :width, :height, :thickness, :quantity, :_destroy]
    )
  end
end
