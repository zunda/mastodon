# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WellKnown::KeybaseProofConfigController do
  render_views

  describe 'GET #show' do
    it 'renders json' do
      get :show

      expect(response).to have_http_status(200)
      expect(response.media_type).to eq 'application/json'
      expect { response.parsed_body }.to_not raise_exception
    end
  end
end
