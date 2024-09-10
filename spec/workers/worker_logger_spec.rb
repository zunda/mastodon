require 'rails_helper'

RSpec.describe WorkerLogger do
  subject { dummy_class.new }
	let(:dummy_class) { Class.new { include WorkerLogger } }

  before do
    allow(Rails.logger).to receive(:info)
  end

  describe 'log_delay' do
    it 'logs useful information' do
      subject.log_delay('2017-09-29T14:22:30Z', 'https://example.com/api', 'delivered', Time.utc(2017, 9, 29, 14, 22, 40))
      %w(destination="https://example.com/api" measure#delivery.delay=10sec count#delivered=1).each do |info|
        expect(Rails.logger).to have_received(:info).with(Regexp.new(info))
      end
    end
  end
end
