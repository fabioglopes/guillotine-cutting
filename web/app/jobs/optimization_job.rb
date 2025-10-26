class OptimizationJob < ApplicationJob
  queue_as :default

  def perform(project_id)
    project = Project.find(project_id)
    
    # Update status to processing
    project.update!(status: 'processing')
    
    # Run optimization
    service = OptimizerService.new(project)
    success = service.run_optimization
    
    if success
      Rails.logger.info "Optimization completed for project #{project.id}"
    else
      # Update status to error
      project.update!(status: 'error')
      Rails.logger.error "Optimization failed for project #{project.id}: #{service.errors.join(', ')}"
    end
  rescue => e
    # Update status to error on exception
    project&.update!(status: 'error')
    Rails.logger.error "Optimization job failed for project #{project_id}: #{e.message}\n#{e.backtrace.join("\n")}"
    raise
  end
end

