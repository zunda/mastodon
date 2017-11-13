require 'rails_helper'

RSpec.describe Notification, type: :model do
  describe '#from_account' do
    pending
  end

  describe '#target_status' do
    before do
      allow(notification).to receive(:type).and_return(type)
      allow(notification).to receive(:activity).and_return(activity)
    end

    let(:notification) { Fabricate(:notification) }
    let(:status)       { instance_double('Status') }
    let(:favourite)    { instance_double('Favourite') }
    let(:mention)      { instance_double('Mention') }

    context 'type is :reblog' do
      let(:type)     { :reblog }
      let(:activity) { status }

      it 'calls activity.reblog' do
        expect(activity).to receive(:reblog)
        notification.target_status
      end
    end

    context 'type is :favourite' do
      let(:type)     { :favourite }
      let(:activity) { favourite }

      it 'calls activity.status' do
        expect(activity).to receive(:status)
        notification.target_status
      end
    end

    context 'type is :mention' do
      let(:type)     { :mention }
      let(:activity) { mention }

      it 'calls activity.status' do
        expect(activity).to receive(:status)
        notification.target_status
      end
    end
  end

  describe '#browserable?' do
    let(:notification) { Fabricate(:notification) }

    subject { notification.browserable? }

    context 'type is :follow_request' do
      before do
        allow(notification).to receive(:type).and_return(:follow_request)
      end

      it 'returns false' do
        is_expected.to be false
      end
    end

    context 'type is not :follow_request' do
      before do
        allow(notification).to receive(:type).and_return(:else)
      end

      it 'returns true' do
        is_expected.to be true
      end
    end
  end

  describe '#type' do
    it 'returns :reblog for a Status' do
      notification = Notification.new(activity: Status.new)
      expect(notification.type).to eq :reblog
    end

    it 'returns :mention for a Mention' do
      notification = Notification.new(activity: Mention.new)
      expect(notification.type).to eq :mention
    end

    it 'returns :favourite for a Favourite' do
      notification = Notification.new(activity: Favourite.new)
      expect(notification.type).to eq :favourite
    end

    it 'returns :follow for a Follow' do
      notification = Notification.new(activity: Follow.new)
      expect(notification.type).to eq :follow
    end
  end

  describe '.reload_stale_associations!' do
    context 'account_ids are empty' do
      let(:cached_items) { [] }

      subject { described_class.reload_stale_associations!(cached_items) }

      it 'returns nil' do
        is_expected.to be nil
      end
    end

    context 'account_ids are present' do
      before do
        allow(accounts_with_ids).to receive(:[]).with(stale_account1.id).and_return(account1)
        allow(accounts_with_ids).to receive(:[]).with(stale_account2.id).and_return(account2)
        allow(Account).to receive_message_chain(:where, :map, :to_h).and_return(accounts_with_ids)
      end

      let(:cached_items) do
        [
          Fabricate(:notification, activity: Fabricate(:status)),
          Fabricate(:notification, activity: Fabricate(:follow)),
        ]
      end

      let(:stale_account1) { cached_items[0].from_account }
      let(:stale_account2) { cached_items[1].from_account }

      let(:account1) { Fabricate(:account) }
      let(:account2) { Fabricate(:account) }

      let(:accounts_with_ids) { { account1.id => account1, account2.id => account2 } }

      it 'reloads associations' do
        expect(cached_items[0].from_account).to be stale_account1
        expect(cached_items[1].from_account).to be stale_account2

        described_class.reload_stale_associations!(cached_items)

        expect(cached_items[0].from_account).to be account1
        expect(cached_items[1].from_account).to be account2
      end
    end
  end
end
