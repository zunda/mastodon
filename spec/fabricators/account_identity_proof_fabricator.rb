# frozen_string_literal: true

Fabricator(:account_identity_proof) do
  account
  provider 'keybase'
  provider_username { sequence(:provider_username) { |_i| Faker::Lorem.characters(number: 15).to_s } }
  token { sequence(:token) { |i| "#{i}#{Faker::Crypto.sha1 * 2}"[0..65] } }
  verified false
  live false
end
