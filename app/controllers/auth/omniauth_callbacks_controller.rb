# frozen_string_literal: true

class Auth::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  include AfterSignInPathLeadable

  skip_before_action :verify_authenticity_token

  def qiita
    auth_hash = request.env['omniauth.auth']

    if current_user
      qiita_authorization = QiitaAuthorization.find_or_initialize_by(uid: auth_hash[:uid]) do |qiita_authorization|
        qiita_authorization.token = auth_hash[:credentials][:token]
        qiita_authorization.user = current_user
      end

      if qiita_authorization.save
        flash[:notice] = I18n.t('omniauth_callbacks.success')
      else
        flash[:alert] = I18n.t('omniauth_callbacks.failure')
      end
      redirect_to after_sign_in_path_for(current_user)
    else
      if authorization = QiitaAuthorization.find_by(uid: auth_hash[:uid])
        sign_in(authorization.user)
        redirect_to after_sign_in_path_for(authorization.user)
      else
        store_omniauth_data
        redirect_to new_user_oauth_registration_path
      end
    end
  end

  def self.provides_callback_for(provider)
    provider_id = provider.to_s.chomp '_oauth2'

    define_method provider do
      @user = User.find_for_oauth(request.env['omniauth.auth'], current_user)

      if @user.persisted?
        sign_in_and_redirect @user, event: :authentication
        set_flash_message(:notice, :success, kind: provider_id.capitalize) if is_navigational_format?
      else
        session["devise.#{provider}_data"] = request.env['omniauth.auth']
        redirect_to new_user_registration_url
      end
    end
  end

  private

  def store_omniauth_data
    session[:devise_omniauth_auth] = request.env['omniauth.auth']
    session[:devise_omniauth_origin] = request.env['omniauth.origin']
  end

  # @override
  def location_after_sign_in
    request.env['omniauth.origin'].presence || stored_location_for(:user)
  end

  Devise.omniauth_configs.each_key do |provider|
    provides_callback_for provider
  end

  def after_sign_in_path_for(resource)
    if resource.email_verified?
      root_path
    else
      finish_signup_path
    end
  end
end
