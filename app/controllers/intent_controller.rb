# frozen_string_literal: true

class IntentController < HomeController
  before_action :set_app_mode_intent

  private

  def set_app_mode_intent
    @app_mode = 'intent'
  end
end
