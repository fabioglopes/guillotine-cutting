module ProjectsHelper
  def status_badge_class(status)
    case status
    when 'draft'
      'bg-gray-100 text-gray-800'
    when 'pending'
      'bg-yellow-100 text-yellow-800'
    when 'processing'
      'bg-blue-100 text-blue-800'
    when 'completed'
      'bg-green-100 text-green-800'
    when 'error'
      'bg-red-100 text-red-800'
    else
      'bg-gray-100 text-gray-800'
    end
  end

  def status_text(status)
    case status
    when 'draft'
      'Rascunho'
    when 'pending'
      'Pendente'
    when 'processing'
      'Processando'
    when 'completed'
      'Concluído'
    when 'error'
      'Erro'
    else
      status.to_s.titleize
    end
  end

  def status_icon(status)
    case status
    when 'draft'
      '📝'
    when 'pending'
      '⏳'
    when 'processing'
      '⚙️'
    when 'completed'
      '✅'
    when 'error'
      '❌'
    else
      '📄'
    end
  end
end
