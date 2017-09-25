# frozen_string_literal: true

if Rake::Task.task_defined?('webpacker:precompile')
  Rake::Task['webpacker:precompile'].enhance do
    html = ApplicationController.render('errors/500', layout: 'error')
    File.write(Rails.root.join('public', '500.html'), html)
  end
end
