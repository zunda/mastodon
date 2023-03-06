# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TranslationService::LibreTranslate do
  subject(:service) { described_class.new('https://libretranslate.example.com', 'my-api-key') }

  before do
    stub_request(:get, 'https://libretranslate.example.com/languages').to_return(
      body: '[{"code": "en","name": "English","targets": ["de","es"]},{"code": "da","name": "Danish","targets": ["en","de"]}]'
    )
  end

  describe '#supported?' do
    it 'supports included language pair' do
      expect(service.supported?('en', 'de')).to be true
    end

    it 'does not support reversed language pair' do
      expect(service.supported?('de', 'en')).to be false
    end

    it 'supports auto-detecting source language' do
      expect(service.supported?(nil, 'de')).to be true
    end

    it 'does not support auto-detecting for unsupported target language' do
      expect(service.supported?(nil, 'pt')).to be false
    end
  end

  describe '#languages' do
    subject(:languages) { service.send(:languages) }

    it 'includes supported source languages' do
      expect(languages.keys).to eq ['en', 'da', nil]
    end

    it 'includes supported target languages for source language' do
      expect(languages['en']).to eq %w(de es)
    end

    it 'includes supported target languages for auto-detected language' do
      expect(languages[nil]).to eq %w(de es en)
    end
  end

  describe '#translate' do
    it 'returns translation with specified source language' do
      stub_request(:post, 'https://libretranslate.example.com/translate')
        .with(body: '{"q":"Hasta la vista","source":"es","target":"en","format":"html","api_key":"my-api-key"}')
        .to_return(body: '{"translatedText": "See you"}')

      translation = service.translate('Hasta la vista', 'es', 'en')
      expect(translation.detected_source_language).to eq 'es'
      expect(translation.provider).to eq 'LibreTranslate'
      expect(translation.text).to eq 'See you'
    end

    it 'returns translation with auto-detected source language' do
      stub_request(:post, 'https://libretranslate.example.com/translate')
        .with(body: '{"q":"Guten Morgen","source":"auto","target":"en","format":"html","api_key":"my-api-key"}')
        .to_return(body: '{"detectedLanguage":{"confidence":92,"language":"de"},"translatedText":"Good morning"}')

      translation = service.translate('Guten Morgen', nil, 'en')
      expect(translation.detected_source_language).to be_nil
      expect(translation.provider).to eq 'LibreTranslate'
      expect(translation.text).to eq 'Good morning'
    end
  end
end
