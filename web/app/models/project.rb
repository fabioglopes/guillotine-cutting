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
  validates :status, inclusion: { in: %w[draft pending processing completed error] }, allow_nil: true

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
  end

  def generate_offcuts!
    # Usar a eficiência geral do projeto
    return unless efficiency.present? && sheets_used.present?
    
    waste_percentage = 100.0 - efficiency
    return if waste_percentage < 5.0  # Só criar sobra se desperdiçou mais de 5%
    
    # Para cada chapa do inventário usada, criar uma sobra
    project_inventory_usages.includes(:inventory_sheet).each do |usage|
      parent = usage.inventory_sheet
      
      # Calcular dimensões da sobra baseado no desperdício
      # Abordagem simplificada: reduz proporcionalmente às dimensões originais
      # waste_percentage é a porcentagem desperdiçada do total
      # Assumindo desperdício distribuído, usar raiz quadrada para calcular redução dimensional
      waste_factor = Math.sqrt(waste_percentage / 100.0)
      
      offcut_width = (parent.width * waste_factor).round
      offcut_height = (parent.height * waste_factor).round
      
      # Não criar sobras muito pequenas (menos de 300mm em qualquer dimensão)
      next if offcut_width < 300 || offcut_height < 300
      
      # Criar uma sobra para cada chapa usada
      usage.quantity_used.times do |i|
        suffix = usage.quantity_used > 1 ? " ##{i + 1}" : ""
        
        InventorySheet.create!(
          label: "♻️ Sobra #{parent.label}#{suffix} (~#{waste_percentage.round}%)",
          width: offcut_width,
          height: offcut_height,
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
