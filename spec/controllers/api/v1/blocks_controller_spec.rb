require 'rails_helper'

RSpec.describe Api::V1::BlocksController, type: :controller do
  render_views

  let(:user)  { Fabricate(:user, account: Fabricate(:account, username: 'alice')) }
  let(:token) { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: 'follow') }

  before do
    Fabricate(:block, account: user.account)
    allow(controller).to receive(:doorkeeper_token) { token }
  end

  describe 'GET #index' do
    it 'returns http success' do
      get :index, params: { limit: 1 }

      expect(response).to have_http_status(:success)
    end
  end
end
