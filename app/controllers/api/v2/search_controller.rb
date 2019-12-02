# frozen_string_literal: true

class Api::V2::SearchController < Api::BaseController
  include Authorization

  RESULTS_LIMIT = 20

  before_action -> { doorkeeper_authorize! :read, :'read:search' }
  before_action :require_user!

  respond_to :json

  def index
    Rails.logger.debug("MARKER: #{__FILE__}:#{__LINE__}")
    @search = Search.new(search_results)
    Rails.logger.debug("MARKER: #{__FILE__}:#{__LINE__}")
    Rails.logger.debug(@search.inspect)
    Rails.logger.debug("MARKER: #{__FILE__}:#{__LINE__}")
    render json: @search, serializer: REST::SearchSerializer
  end

  private

  def search_results
    SearchService.new.call(
      params[:q],
      current_account,
      limit_param(RESULTS_LIMIT),
      search_params.merge(resolve: truthy_param?(:resolve), exclude_unreviewed: truthy_param?(:exclude_unreviewed))
    )
  end

  def search_params
    params.permit(:type, :offset, :min_id, :max_id, :account_id)
  end
end
