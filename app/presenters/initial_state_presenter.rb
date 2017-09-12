# frozen_string_literal: true

class InitialStatePresenter < ActiveModelSerializers::Model
  attributes :settings, :push_subscription, :token, :current_account, :admin, :app_mode, :intent_status_initial_text
end
