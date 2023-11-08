# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'

# This needs to be defined before Rails is initialized
RUN_SYSTEM_SPECS = ENV.fetch('RUN_SYSTEM_SPECS', false)
RUN_SEARCH_SPECS = ENV.fetch('RUN_SEARCH_SPECS', false)

if RUN_SYSTEM_SPECS
  STREAMING_PORT = ENV.fetch('TEST_STREAMING_PORT', '4020')
  ENV['STREAMING_API_BASE_URL'] = "http://localhost:#{STREAMING_PORT}"
end

require File.expand_path('../config/environment', __dir__)

abort('The Rails environment is running in production mode!') if Rails.env.production?

require 'spec_helper'
require 'rspec/rails'
require 'webmock/rspec'
require 'paperclip/matchers'
require 'capybara/rspec'
require 'chewy/rspec'

Dir[Rails.root.join('spec', 'support', '**', '*.rb')].each { |f| require f }

ActiveRecord::Migration.maintain_test_schema!
WebMock.disable_net_connect!(allow: Chewy.settings[:host], allow_localhost: RUN_SYSTEM_SPECS)
Sidekiq::Testing.inline!
Sidekiq.logger = nil

# System tests config
DatabaseCleaner.strategy = [:deletion]

Devise::Test::ControllerHelpers.module_eval do
  alias_method :original_sign_in, :sign_in

  def sign_in(resource, _deprecated = nil, scope: nil)
    original_sign_in(resource, scope: scope)

    SessionActivation.deactivate warden.cookies.signed['_session_id']

    warden.cookies.signed['_session_id'] = {
      value: resource.activate_session(warden.request),
      expires: 1.year.from_now,
      httponly: true,
    }
  end
end

RSpec.configure do |config|
  # This is set before running spec:system, see lib/tasks/tests.rake
  config.filter_run_excluding type: lambda { |type|
    case type
    when :system
      !RUN_SYSTEM_SPECS
    when :search
      !RUN_SEARCH_SPECS
    end
  }
  config.fixture_path = Rails.root.join('spec', 'fixtures')
  config.use_transactional_fixtures = true
  config.order = 'random'
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!

  config.define_derived_metadata(file_path: Regexp.new('spec/lib/mastodon/cli')) do |metadata|
    metadata[:type] = :cli
  end

  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include Devise::Test::ControllerHelpers, type: :helper
  config.include Devise::Test::ControllerHelpers, type: :view
  config.include Devise::Test::IntegrationHelpers, type: :feature
  config.include Devise::Test::IntegrationHelpers, type: :request
  config.include Paperclip::Shoulda::Matchers
  config.include ActiveSupport::Testing::TimeHelpers
  config.include Chewy::Rspec::Helpers
  config.include Redisable
  config.include SignedRequestHelpers, type: :request

  config.around(:each, use_transactional_tests: false) do |example|
    self.use_transactional_tests = false
    example.run
    self.use_transactional_tests = true
  end

  config.before :each, type: :cli do
    stub_stdout
    stub_reset_connection_pools
  end

  config.before :each, type: :feature do
    Capybara.current_driver = :rack_test
  end

  config.around :each, type: :system do |example|
    driven_by :selenium, using: :headless_chrome, screen_size: [1600, 1200]

    # The streaming server needs access to the database
    # but with use_transactional_tests every transaction
    # is rolled-back, so the streaming server never sees the data
    # So we disable this feature for system tests, and use DatabaseCleaner to clean
    # the database tables between each test
    self.use_transactional_tests = false

    DatabaseCleaner.cleaning do
      example.run
    end

    self.use_transactional_tests = true
  end

  config.before do |example|
    unless example.metadata[:paperclip_processing]
      allow_any_instance_of(Paperclip::Attachment).to receive(:post_process).and_return(true) # rubocop:disable RSpec/AnyInstance
    end
  end

  config.after do
    Rails.cache.clear
    redis.del(redis.keys)
  end

  # Assign types based on dir name for non-inferred types
  config.define_derived_metadata(file_path: %r{/spec/}) do |metadata|
    unless metadata.key?(:type)
      match = metadata[:location].match(%r{/spec/([^/]+)/})
      metadata[:type] = match[1].singularize.to_sym
    end
  end
end

RSpec::Sidekiq.configure do |config|
  config.warn_when_jobs_not_processed_by_sidekiq = false
end

RSpec::Matchers.define_negated_matcher :not_change, :change

def request_fixture(name)
  Rails.root.join('spec', 'fixtures', 'requests', name).read
end

def attachment_fixture(name)
  Rails.root.join('spec', 'fixtures', 'files', name).open
end

def stub_stdout
  # TODO: Is there a bettery way to:
  # - Avoid CLI command output being printed out
  # - Allow rspec to assert things against STDOUT
  # - Avoid disabling stdout for other desirable output (deprecation warnings, for example)
  allow($stdout).to receive(:write)
end

def stub_reset_connection_pools
  # TODO: Is there a better way to correctly run specs without stubbing this?
  # (Avoids reset_connection_pools! in test env)
  allow(ActiveRecord::Base).to receive(:establish_connection)
  allow(RedisConfiguration).to receive(:establish_pool)
end
