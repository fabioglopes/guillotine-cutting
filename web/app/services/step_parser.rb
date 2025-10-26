# Parser for STEP files to extract rectangular panel dimensions
# Supports ISO-10303-21 (STEP AP242) format
require 'set'

class StepParser
  attr_reader :parts, :errors

  def initialize(file_path)
    @file_path = file_path
    @parts = []
    @errors = []
    @entities = {}
  end

  def parse
    unless File.exist?(@file_path)
      @errors << "File not found: #{@file_path}"
      return false
    end

    begin
      content = File.read(@file_path)
      
      # Check if it's a valid STEP file
      unless content.start_with?('ISO-10303-21')
        @errors << "Invalid STEP file format"
        return false
      end

      # Parse all entities into a hash for reference
      parse_entities(content)
      
      # Extract parts and their dimensions
      extract_parts
      
      return @parts.any?
    rescue => e
      @errors << "Error parsing STEP file: #{e.message}\n#{e.backtrace.first(5).join("\n")}"
      return false
    end
  end

  private

  def parse_entities(content)
    # Extract DATA section
    data_section = content[/DATA;(.*)ENDSEC;/m, 1]
    return unless data_section

    # Parse each entity line
    data_section.scan(/#(\d+)=([^;]+);/) do |id, definition|
      @entities[id.to_i] = definition.strip
    end
  end

  def extract_parts
    # Find all MANIFOLD_SOLID_BREP entities (each represents one solid part)
    breps = @entities.select { |id, def_str| def_str.start_with?('MANIFOLD_SOLID_BREP(') }
    
    breps.each do |brep_id, brep_def|
      # Extract part name from MANIFOLD_SOLID_BREP('Part Name',...)
      if brep_def =~ /MANIFOLD_SOLID_BREP\('([^']+)',#(\d+)\)/
        part_name = $1
        shell_ref = $2.to_i
        
        # Find points specific to this BREP by traversing the geometry tree
        points = find_points_for_brep(brep_id, shell_ref)
        
        next if points.empty?
        
        # Calculate bounding box for this specific part
        dimensions = calculate_bounding_box(points)
        
        if dimensions
          @parts << {
            name: part_name,
            width: dimensions[:width],
            height: dimensions[:height],
            depth: dimensions[:depth],
            bounding_box: dimensions
          }
        end
      end
    end

    # Sort by name for consistent ordering
    @parts.sort_by! { |p| p[:name] }
  end

  def find_points_for_brep(brep_id, shell_ref)
    # Start with the CLOSED_SHELL referenced by the BREP
    visited = Set.new
    points = []
    queue = [shell_ref]
    
    # BFS to find all related entities
    while !queue.empty?
      current_id = queue.shift
      next if visited.include?(current_id)
      visited.add(current_id)
      
      entity_def = @entities[current_id]
      next unless entity_def
      
      # If this is a CARTESIAN_POINT, extract coordinates
      if entity_def.start_with?('CARTESIAN_POINT(')
        if entity_def =~ /CARTESIAN_POINT\('[^']*',\(([^)]+)\)\)/
          coords = $1.split(',').map { |c| c.strip.to_f }
          points << coords if coords.length == 3
        end
      end
      
      # Find all entity references in this definition (e.g., #123)
      entity_def.scan(/#(\d+)/).each do |match|
        ref_id = match[0].to_i
        queue << ref_id unless visited.include?(ref_id)
      end
    end
    
    points
  end

  def calculate_bounding_box(points)
    return nil if points.empty?
    
    # Calculate bounding box
    min_x = points.map { |p| p[0] }.min
    max_x = points.map { |p| p[0] }.max
    min_y = points.map { |p| p[1] }.min
    max_y = points.map { |p| p[1] }.max
    min_z = points.map { |p| p[2] }.min
    max_z = points.map { |p| p[2] }.max

    # Calculate dimensions (convert from meters to millimeters)
    width = ((max_x - min_x) * 1000).round(1)
    height = ((max_y - min_y) * 1000).round(1)
    depth = ((max_z - min_z) * 1000).round(1)

    # For rectangular panels, typically we want the two largest dimensions
    dimensions = [width, height, depth].sort.reverse

    {
      width: dimensions[0],
      height: dimensions[1],
      depth: dimensions[2],
      min: [min_x * 1000, min_y * 1000, min_z * 1000],
      max: [max_x * 1000, max_y * 1000, max_z * 1000]
    }
  end

  public

  # Public method to get parts as Piece objects
  def to_pieces(thickness_threshold: 20)
    pieces = []
    
    @parts.each_with_index do |part, idx|
      # Determine which dimensions to use (exclude thickness dimension)
      dims = [part[:width], part[:height], part[:depth]].sort.reverse
      
      # If one dimension is significantly smaller, it's likely the thickness
      # Use the two larger dimensions
      width = dims[0]
      height = dims[1]
      thickness = dims[2]  # Smallest dimension is the thickness
      
      # Create piece with default quantity of 1
      piece_id = "P#{idx + 1}"
      label = part[:name]
      
      pieces << {
        id: piece_id,
        width: width.round,
        height: height.round,
        thickness: thickness.round(1),
        quantity: 1,
        label: label,
        source: 'STEP'
      }
    end
    
    pieces
  end
  
  # Group parts by thickness
  def group_by_thickness
    thickness_groups = {}
    
    to_pieces.each do |piece|
      thickness = piece[:thickness]
      thickness_groups[thickness] ||= []
      thickness_groups[thickness] << piece
    end
    
    thickness_groups
  end

  # Generate a summary report
  def summary
    return "No parts found" if @parts.empty?
    
    lines = []
    lines << "=== STEP File Analysis ==="
    lines << "File: #{File.basename(@file_path)}"
    lines << "Parts found: #{@parts.length}"
    lines << ""
    
    @parts.each do |part|
      lines << "#{part[:name]}:"
      lines << "  Dimensions: #{part[:width].round(1)} x #{part[:height].round(1)} x #{part[:depth].round(1)} mm"
      lines << "  Area (2 largest dims): #{(part[:width] * part[:height] / 1000000.0).round(2)} m²"
      lines << ""
    end
    
    lines.join("\n")
  end
end
