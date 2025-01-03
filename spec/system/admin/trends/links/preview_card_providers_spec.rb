# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin::Trends::Links::PreviewCardProviders' do
  let(:current_user) { Fabricate(:admin_user) }

  before do
    sign_in current_user
  end

  describe 'Performing batch updates' do
    before do
      visit admin_trends_links_preview_card_providers_path
    end

    context 'without selecting any records' do
      it 'displays a notice about selection' do
        click_on button_for_allow

        expect(page).to have_content(selection_error_text)
      end
    end

    def button_for_allow
      I18n.t('admin.trends.allow')
    end

    def selection_error_text
      I18n.t('admin.trends.links.publishers.no_publisher_selected')
    end
  end
end
