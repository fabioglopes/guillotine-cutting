class Project < ApplicationRecord
  has_many :sheets, dependent: :destroy
  has_many :pieces, dependent: :destroy
  has_one_attached :input_file
  has_many_attached :result_files
  
  has_many :project_inventory_usages, dependent: :destroy
  has_many :inventory_sheets, through: :project_inventory_usages

  accepts_nested_attributes_for :sheets, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :pieces, allow_destroy: true, reject_if: :all_blank

  validates :name, presence: true
  validates :cutting_width, numericality: { greater_than: 0 }, allow_nil: true
  validates :thickness, numericality: { greater_than: 0 }, allow_nil: true
  validates :status, inclusion: { in: %w[draft pending processing completed error] }, allow_nil: true
  validates :optimization_algorithm, inclusion: { in: %w[two_stage_guillotine raster_point_dp cutting_optimizer] }, allow_nil: true
  validate :thickness_required_for_inventory, if: :use_inventory?

  before_validation :set_defaults, on: :create

  scope :recent, -> { order(created_at: :desc) }
  scope :completed, -> { where(status: 'completed') }
  scope :pending, -> { where(status: 'pending') }
  scope :cut_completed, -> { where(cut_completed: true) }
  scope :pending_cut, -> { where(cut_completed: false).where.not(status: 'draft') }

  def optimized?
    status == 'completed'
  end

  def can_optimize?
    (sheets.any? || input_file.attached? || use_inventory?) && pieces.any?
  end

  def mark_as_cut_completed!
    transaction do
      # Reserva as chapas do inventário (só agora consome definitivamente)
      if use_inventory? && project_inventory_usages.any?
        project_inventory_usages.includes(:inventory_sheet).each do |usage|
          # Reserva as chapas (decrementa available_quantity)
          unless usage.inventory_sheet.reserve!(usage.quantity_used)
            raise ActiveRecord::Rollback, "Não há chapas suficientes no inventário"
          end
        end
        
        # Gerar sobras automaticamente
        generate_offcuts!
      end
      
      update!(cut_completed: true, cut_completed_at: Time.current)
    end
  end

  def unmark_as_cut_completed!
    return unless cut_completed?
    
    transaction do
      # Devolve as chapas ao inventário (incrementa available_quantity)
      if use_inventory? && project_inventory_usages.any?
        project_inventory_usages.includes(:inventory_sheet).each do |usage|
          usage.inventory_sheet.release!(usage.quantity_used)
        end
        
        # Remover sobras geradas por este projeto
        InventorySheet.where(source_project_id: id, is_offcut: true).destroy_all
      end
      
      update!(cut_completed: false, cut_completed_at: nil)
    end
  end

  def release_inventory!
    return unless use_inventory?
    
    transaction do
      project_inventory_usages.includes(:inventory_sheet).each do |usage|
        usage.inventory_sheet.release!(usage.quantity_used)
      end
    end
  end

  private

  def set_defaults
    self.allow_rotation = true if allow_rotation.nil?
    self.cutting_width ||= 3
    self.status ||= 'draft'
    self.optimization_algorithm ||= 'two_stage_guillotine'
  end

  def thickness_required_for_inventory
    if thickness.blank?
      errors.add(:thickness, 'é obrigatória quando usar inventário')
    end
  end

  def generate_offcuts!
    return unless optimization_data.present? && use_inventory?
    
    begin
      sheets_data = JSON.parse(optimization_data)
    rescue JSON::ParserError
      Rails.logger.error("Failed to parse optimization_data for project #{id}")
      return
    end
    
    # Para cada chapa usada, calcular sobras reais
    sheets_data.each do |sheet_data|
      # Encontrar a chapa pai no inventário
      base_label = sheet_data['label'].gsub(/ #\d+$/, '')
      parent = InventorySheet.find_by(label: base_label)
      next unless parent
      
      # Reconstruir objeto OptimizerSheet para usar método calculate_offcuts
      sheet = OptimizerSheet.new(
        sheet_data['id'],
        sheet_data['width'].to_f,
        sheet_data['height'].to_f,
        sheet_data['label']
      )
      sheet.cutting_width = (sheet_data['cutting_width'] || cutting_width || 3).to_f
      
      # Adicionar peças colocadas
      sheet_data['placed_pieces'].each do |pp_data|
        # Criar peça temporária
        piece = OptimizerPiece.new(
          'temp',
          pp_data['width'].to_f,
          pp_data['height'].to_f,
          1
        )
        sheet.add_piece(piece, pp_data['x'].to_f, pp_data['y'].to_f, pp_data['rotated'])
      end
      
      # Calcular sobras reais desta chapa
      offcuts = sheet.calculate_offcuts(200) # mínimo 200mm
      
      # Criar registro de inventário para cada sobra
      offcuts.each_with_index do |offcut, index|
        suffix = offcuts.length > 1 ? " (#{index + 1})" : ""
        
        InventorySheet.create!(
          label: "♻️ Sobra #{sheet_data['label']}#{suffix}",
          width: offcut[:width],
          height: offcut[:height],
          thickness: parent.thickness,
          material: parent.material,
          quantity: 1,
          available_quantity: 1,
          is_offcut: true,
          parent_sheet_id: parent.id,
          source_project_id: id
        )
      end
    end
  end
end
