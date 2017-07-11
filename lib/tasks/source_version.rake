namespace :source do
  desc 'Record source version'
  task :version do
    hash = ENV['SOURCE_VERSION']  # available on Heroku while build
    if hash.blank?
      begin
        hash = `git show --pretty=%H 2>/dev/null`.strip
        # ignore the error: fatal: Not a git repository
      rescue Errno::ENOENT  # git command is not available
      end
    end
    unless hash.blank?
      hash_abb = hash[0..7]
      File.open('config/initializers/version.rb', 'w') do |f|
        f.write <<~_TEMPLATE
          # frozen_string_literal: true
          module Mastodon
            module Version
              module_function

              def to_s
                "\#{to_a.join('.')} at #{hash_abb}"
              end
            end
          end
        _TEMPLATE
      end
    end
  end
end

task 'assets:precompile' => ['source:version']
