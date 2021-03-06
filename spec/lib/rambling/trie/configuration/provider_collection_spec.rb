# frozen_string_literal: true

require 'spec_helper'

describe Rambling::Trie::Configuration::ProviderCollection do
  let(:configured_default) { nil }
  let(:configured_providers) do
    { one: first_provider, two: second_provider }
  end

  let(:first_provider) { double :first_provider }
  let(:second_provider) { double :second_provider }

  let(:provider_collection) do
    Rambling::Trie::Configuration::ProviderCollection.new(
      :provider,
      configured_providers,
      configured_default,
    )
  end

  describe '.new' do
    it 'has a name' do
      expect(provider_collection.name).to eq :provider
    end

    it 'has the given providers' do
      expect(provider_collection.providers)
        .to eq one: first_provider, two: second_provider
    end

    it 'has a default provider' do
      expect(provider_collection.default).to eq first_provider
    end

    context 'when a default is provided' do
      let(:configured_default) { second_provider }

      it 'has that as the default provider' do
        expect(provider_collection.default).to eq second_provider
      end
    end
  end

  describe 'aliases and delegates' do
    let(:providers) { provider_collection.providers }

    before do
      allow(providers) .to receive_messages(
        :[] => 'value',
        keys: %i(a b),
      )
    end

    it 'delegates `#[]` to providers' do
      expect(provider_collection[:key]).to eq 'value'
      expect(providers).to have_received(:[]).with :key
    end

    it 'aliases `#formats` to `providers#keys`' do
      expect(provider_collection.formats).to eq %i(a b)
      expect(providers).to have_received :keys
    end
  end

  describe '#add' do
    let(:provider) { double :provider }

    before do
      provider_collection.add :three, provider
    end

    it 'adds a new provider' do
      expect(provider_collection.providers[:three]).to eq provider
    end
  end

  describe '#default=' do
    let(:other_provider) { double :other_provider }

    context 'when the given value is in the providers list' do
      it 'changes the default provider' do
        provider_collection.default = second_provider
        expect(provider_collection.default).to eq second_provider
      end
    end

    context 'when the given value is not in the providers list' do
      it 'raises an error and keeps the default provider' do
        expect { provider_collection.default = other_provider }
          .to raise_error(ArgumentError)
          .and(not_change { provider_collection.default })
      end

      it 'raises an ArgumentError' do
        expect { provider_collection.default = other_provider }
          .to raise_error ArgumentError
      end
    end

    context 'when the providers list is empty' do
      let(:configured_providers) { {} }

      it 'accepts nil' do
        provider_collection.default = nil
        expect(provider_collection.default).to be_nil
      end

      it 'raises an ArgumentError for any other provider' do
        expect do
          provider_collection.default = other_provider
        end.to raise_error ArgumentError
        expect(provider_collection.default).to be_nil
      end
    end
  end

  describe '#resolve' do
    context 'when the file extension is one of the providers' do
      it 'returns the corresponding provider' do
        expect(provider_collection.resolve 'hola.one').to eq first_provider
        expect(provider_collection.resolve 'hola.two').to eq second_provider
      end
    end

    context 'when the file extension is not one of the providers' do
      it 'returns the default provider' do
        expect(provider_collection.resolve 'hola.unknown').to eq first_provider
        expect(provider_collection.resolve 'hola').to eq first_provider
      end
    end
  end

  describe '#reset' do
    let(:configured_default) { second_provider }
    let(:provider) { double :provider }

    before do
      provider_collection.add :three, provider
      provider_collection.default = provider
    end

    it 'resets to back to the initially configured values' do
      provider_collection.reset
      expect(provider_collection[:three]).to be_nil
      expect(provider_collection.default).to eq second_provider
    end
  end
end
