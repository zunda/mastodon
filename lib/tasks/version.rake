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
      mastodon_version_to_s = Mastodon::Version.to_s
      File.open('config/initializers/version.rb', 'w') do |f|
        f.write <<~_TEMPLATE
          # frozen_string_literal: true
          module Mastodon
            module Version
              module_function

              def to_s
                "#{mastodon_version_to_s} at #{hash_abb}"
              end
            end

            module Source
              module_function

              def base_url
                'https://github.com/zunda/mastodon'
              end
              def tag
                "#{hash}"
              end
            end
          end
        _TEMPLATE
      end
    end
  end
end

task 'assets:precompile' => ['source:version']
