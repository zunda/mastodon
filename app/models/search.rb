# frozen_string_literal: true

class Search < ActiveModelSerializers::Model
  attributes :accounts, :statuses, :hashtags

  def initialize
    Rails.logger.debug("MARKER: #{__FILE__}:#{__LINE__}")
    super
    Rails.logger.debug("MARKER: #{__FILE__}:#{__LINE__}")
  end
end
