class AssetsController < ApplicationController
  before_action :set_asset, only: [:show, :recalculate_balance]

  def index
    @assets = Asset.all.order(balance: :desc)
    log_info("Fetched all assets")
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
