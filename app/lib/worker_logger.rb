# frozen_string_literal: true
require 'time'

module WorkerLogger
  def log_delay(published, url, at)
    return unless published
    begin
      delay = Time.now - Time.parse(published)
      logger.info "source=#{self.class} destination=#{url.inspect} measure#delivery.delay=#{'%.0f' % delay}sec count##{at}=1"
    #rescue
      # Ignore possible parse errors from Time.parse
    end
  end
end
