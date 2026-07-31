# frozen_string_literal: true

class Api::V1::Accounts::IdentityProofsController < Api::BaseController
  include DeprecationConcern

  deprecate_api '2022-03-30'

  before_action :require_user!

  def index
    @proofs = @account.suspended? ? [] : @account.identity_proofs.active
    render json: @proofs, each_serializer: REST::IdentityProofSerializer
  end
end
