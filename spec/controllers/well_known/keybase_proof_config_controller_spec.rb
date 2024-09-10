require 'rails_helper'

RSpec.describe WellKnown::KeybaseProofConfigController, type: :controller do
  render_views

  describe 'GET #show' do
    xit 'renders json' do
      get :show

      expect(response).to have_http_status(200)
      expect(response.media_type).to eq 'application/json'
      expect { JSON.parse(response.body) }.not_to raise_exception
    end
  end
end
