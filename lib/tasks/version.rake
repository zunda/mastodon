# frozen_string_literal: true

namespace :source do
  desc 'Record source version'
  task version: :environment do
    hash = ENV.fetch('SOURCE_VERSION', nil) # available on Heroku while build
    if hash.blank?
      begin
        hash = `git rev-parse HEAD 2>/dev/null`.strip
        # ignore the error: fatal: Not a git repository
      rescue Errno::ENOENT
        # git command is not available
      end
    end
    if hash.present?
      hash_abb = hash[0..7]
      File.write('config/initializers/version.rb', <<~_TEMPLATE)
        # frozen_string_literal: true

        module Mastodon
          module Version
            module_function

            def suffix
              ' at #{hash_abb} on ruby-#{RUBY_VERSION}'
            end

            def build_metadata
              '#{hash_abb}-ruby-#{RUBY_VERSION}'
            end

            def repository
              'zunda/mastodon'
            end

            def source_tag
              '#{hash}'
            end
          end
        end
      _TEMPLATE
    end
  end
end

task 'assets:precompile' => ['source:version']
