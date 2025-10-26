class InventorySheetsController < ApplicationController
  before_action :set_inventory_sheet, only: [:edit, :update, :destroy]

  def index
    @inventory_sheets = InventorySheet.order(:is_offcut, :label)
    @total_sheets = @inventory_sheets.sum(:quantity)
    @available_sheets = @inventory_sheets.sum(:available_quantity)
    @offcuts_count = @inventory_sheets.offcuts.count
  end

  def new
    @inventory_sheet = InventorySheet.new
  end

  def create
    @inventory_sheet = InventorySheet.new(inventory_sheet_params)

    if @inventory_sheet.save
      redirect_to inventory_sheets_path, notice: 'Chapa adicionada ao inventário com sucesso.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @inventory_sheet.update(inventory_sheet_params)
      redirect_to inventory_sheets_path, notice: 'Chapa atualizada com sucesso.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @inventory_sheet.projects.any?
      redirect_to inventory_sheets_path, alert: 'Não é possível excluir. Esta chapa foi usada em projetos.'
    else
      @inventory_sheet.destroy
      redirect_to inventory_sheets_path, notice: 'Chapa removida do inventário.'
    end
  end

  private

  def set_inventory_sheet
    @inventory_sheet = InventorySheet.find(params[:id])
  end

  def inventory_sheet_params
    params.require(:inventory_sheet).permit(:label, :width, :height, :thickness, :material, :quantity, :available_quantity)
  end
end
