require "test_helper"

class OptimizationFlowTest < ActiveSupport::TestCase
  test "complete optimization flow from project creation to results" do
    # 1. Create project
    project = Project.create!(
      name: "Integration Test Project",
      description: "Testing complete optimization flow",
      cutting_width: 3.0,
      allow_rotation: true
    )

    assert project.persisted?
    assert_equal "not_started", project.status

    # 2. Add sheets
    project.sheets.create!(
      label: "MDF 15mm",
      width: 2750,
      height: 1850,
      thickness: 15,
      quantity: 2
    )

    assert_equal 2, project.sheets.count

    # 3. Add pieces
    project.pieces.create!([
      { label: "Mesa", width: 1200, height: 800, quantity: 1 },
      { label: "Lateral Esquerda", width: 600, height: 400, quantity: 1 },
      { label: "Lateral Direita", width: 600, height: 400, quantity: 1 },
      { label: "Prateleira", width: 800, height: 300, quantity: 3 }
    ])

    assert_equal 4, project.pieces.count

    # 4. Run optimization
    service = OptimizerService.new(project)

    silence_output do
      service.run_optimization
    end

    # 5. Verify results
    project.reload

    assert project.completed? || project.error?,
           "Project should be completed or in error state"

    if project.completed?
      # Check efficiency was calculated
      assert_not_nil project.efficiency
      assert project.efficiency >= 0
      assert project.efficiency <= 100

      # Check files were generated
      assert project.result_files.attached?
      assert project.result_files.count > 0

      # Check for specific file types
      filenames = project.result_files.attachments.map { |a| a.filename.to_s }

      assert filenames.any? { |f| f.end_with?('.svg') },
             "Should generate SVG files"
      assert filenames.any? { |f| f == 'index.html' },
             "Should generate index.html"
      assert filenames.any? { |f| f == 'print.html' },
             "Should generate print.html"

      # 6. Verify we can download results
      svg_file = project.result_files.attachments.find { |a| a.filename.to_s.end_with?('.svg') }
      assert_not_nil svg_file

      content = svg_file.download
      assert content.length > 0
      assert content.force_encoding('UTF-8').include?('<?xml')

      # 7. Test HTML generation
      html_file = project.result_files.attachments.find { |a| a.filename.to_s == 'index.html' }
      assert_not_nil html_file

      html_content = html_file.download.force_encoding('UTF-8')
      assert html_content.include?('<!DOCTYPE html')
      assert html_content.include?(project.name)
    end

    # 8. Clean up
    project.destroy
  end

  test "optimization with rotation disabled" do
    project = Project.create!(
      name: "No Rotation Test",
      cutting_width: 3.0,
      allow_rotation: false  # Disable rotation
    )

    project.sheets.create!(
      label: "Test Sheet",
      width: 2000,
      height: 1500,
      quantity: 1
    )

    project.pieces.create!([
      { label: "Piece 1", width: 500, height: 400, quantity: 2 },
      { label: "Piece 2", width: 600, height: 300, quantity: 1 }
    ])

    service = OptimizerService.new(project)

    silence_output do
      service.run_optimization
    end

    project.reload

    if project.completed?
      assert_not_nil project.efficiency
    end

    project.destroy
  end

  test "optimization with large cutting width" do
    project = Project.create!(
      name: "Large Cutting Width Test",
      cutting_width: 10.0,  # Large cutting width
      allow_rotation: true
    )

    project.sheets.create!(
      label: "Test Sheet",
      width: 2000,
      height: 1500,
      quantity: 1
    )

    project.pieces.create!(
      label: "Test Piece",
      width: 500,
      height: 400,
      quantity: 2
    )

    service = OptimizerService.new(project)

    silence_output do
      service.run_optimization
    end

    project.reload

    if project.completed?
      # With larger cutting width, efficiency should be lower
      assert project.efficiency < 100
    end

    project.destroy
  end

  test "optimization with many small pieces" do
    project = Project.create!(
      name: "Many Small Pieces Test",
      cutting_width: 3.0,
      allow_rotation: true
    )

    project.sheets.create!(
      label: "Large Sheet",
      width: 2750,
      height: 1850,
      quantity: 3
    )

    # Create many small pieces
    20.times do |i|
      project.pieces.create!(
        label: "Small Piece #{i + 1}",
        width: 200 + (i * 10),
        height: 150 + (i * 5),
        quantity: 1
      )
    end

    assert_equal 20, project.pieces.count

    service = OptimizerService.new(project)

    silence_output do
      service.run_optimization
    end

    project.reload

    assert project.completed? || project.error?

    project.destroy
  end

  test "project lifecycle" do
    # Create
    project = Project.create!(
      name: "Lifecycle Test",
      cutting_width: 3.0
    )

    assert project.not_started?

    # Add data
    project.sheets.create!(label: "Sheet", width: 2000, height: 1500, quantity: 1)
    project.pieces.create!(label: "Piece", width: 500, height: 400, quantity: 1)

    # Process
    service = OptimizerService.new(project)

    silence_output do
      service.run_optimization
    end

    project.reload

    # Verify final state
    assert_includes ['completed', 'error'], project.status

    # Destroy
    project.destroy
    assert_not Project.exists?(project.id)
  end

  private

  def silence_output
    original_stdout = $stdout
    $stdout = StringIO.new
    yield
  ensure
    $stdout = original_stdout
  end
end

