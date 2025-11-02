class AssetsController < ApplicationController
  include SortParamGuard

  before_action :set_asset, only: [:show, :recalculate_balance]

  def index
    if params[:asset] && !params[:asset].strip.empty?
      normalise_asset = params[:asset].upcase.strip
      @assets = Asset.search_by_asset(normalise_asset).order_by_column(params[:sort_by])
      log_info("Searched assets by name: #{normalise_asset}")
    else
      @assets = Asset.all.order_by_column(params[:sort_by])
      log_info("Fetched all assets")
      log_info("Sorted assets by #{params[:sort_by]}")
    end
  end

  def show
    @transactions = @asset.transactions.order(time: :desc)
    log_info("Viewing asset: #{@asset.name}")
  rescue ActiveRecord::RecordNotFound
    log_error("Asset not found with name: #{params[:id]}")
    redirect_to assets_path, alert: 'Asset not found.'
  end

  def recalculate_balance
    @asset.recalculate_balance!
    log_info("Recalculated balance for asset: #{@asset.name}")
    redirect_to asset_path(@asset), notice: "#{@asset.name} balance recalculated."
  rescue ActiveRecord::RecordNotFound
    log_error("Asset not found with name: #{params[:id]} for balance recalculation")
    redirect_to assets_path, alert: 'Asset not found.'
  end

  private

  def set_asset
    @asset = Asset.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    log_error("Asset not found with name: #{params[:id]}")
    redirect_to assets_path, alert: 'Asset not found.'
  end
end
