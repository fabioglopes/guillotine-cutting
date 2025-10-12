# Unified input loader for YAML files
require_relative 'piece'
require_relative 'sheet'
require 'yaml'

class InputLoader
  attr_reader :errors, :warnings

  def initialize
    @errors = []
    @warnings = []
  end

  def load_file(file_path)
    unless File.exist?(file_path)
      @errors << "File not found: #{file_path}"
      return nil
    end

    extension = File.extname(file_path).downcase
    
    case extension
    when '.yml', '.yaml'
      load_yaml(file_path)
    else
      @errors << "Unsupported file format: #{extension}. Only .yml and .yaml files are supported."
      @errors << "For STEP files, convert first: ruby cut_optimizer.rb -f yourfile.step"
      nil
    end
  end

  private

  def load_yaml(file_path)
    begin
      data = YAML.load_file(file_path)
      
      # Support both Portuguese and English field names
      sheets = parse_sheets(
        data['chapas_disponiveis'] || 
        data['available_sheets']
      )
      
      pieces = parse_pieces(
        data['pecas_necessarias'] || 
        data['required_pieces']
      )
      
      if sheets.empty?
        @errors << "No sheets defined in YAML file"
      end
      
      if pieces.empty?
        @errors << "No pieces defined in YAML file"
      end
      
      return nil if @errors.any?
      
      { sheets: sheets, pieces: pieces, source: 'yaml' }
    rescue => e
      @errors << "Error reading YAML file: #{e.message}"
      nil
    end
  end

  def parse_sheets(sheets_data)
    return [] unless sheets_data

    sheets = []
    sheets_data.each_with_index do |data, idx|
      # Support both Portuguese and English field names
      width = data['largura'] || data['width']
      height = data['altura'] || data['height']
      thickness = data['espessura'] || data['thickness']
      quantity = data['quantidade'] || data['quantity'] || 1
      label = data['identificacao'] || data['label']
      
      # Add thickness to label if provided
      if thickness && label && !label.include?(thickness.to_s)
        label = "#{label} #{thickness}mm"
      end

      quantity.times do |i|
        sheet_id = "S#{idx + 1}.#{i + 1}"
        sheet_label = label ? "#{label} ##{i + 1}" : "Chapa #{idx + 1}.#{i + 1}"
        sheets << Sheet.new(sheet_id, width, height, sheet_label)
      end
    end
    sheets
  end

  def parse_pieces(pieces_data)
    return [] unless pieces_data

    pieces_data.map.with_index do |data, idx|
      # Support both Portuguese and English field names
      width = data['largura'] || data['width']
      height = data['altura'] || data['height']
      thickness = data['espessura'] || data['thickness']
      quantity = data['quantidade'] || data['quantity'] || 1
      label = data['identificacao'] || data['label'] || "Peça #{idx + 1}"
      
      # Add thickness to label if provided
      if thickness && !label.include?(thickness.to_s)
        label = "#{label} (#{thickness}mm)"
      end

      Piece.new("P#{idx + 1}", width, height, quantity, label)
    end
  end
end
