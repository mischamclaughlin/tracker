class CoinsController < ApplicationController
  before_action :set_coin, only: %i[ show edit update destroy ]

  def index
    @coins = Coin.all
    log_info("Fetched all coins")
  end

  def show
    log_info("Fetched coin: #{@coin.id}")
  rescue ActiveRecord::RecordNotFound
    log_error("Coin not found with id: #{params[:id]}")
    redirect_to coins_path, alert: 'Coin not found.'
  end

  def new
    @coin = Coin.new
  end

  def edit
  end

  def create
    @coin = Coin.new(coin_params)
    log_info("Coin Params: #{coin_params.inspect}")

    if @coin.save
      log_info("Created coin with ID #{@coin.id}")
      redirect_to @coin, notice: "Coin was successfully created.", status: :see_other
    else
      log_error("Failed to create coin: #{@coin.errors.full_messages.join(', ')}")
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @coin.update(coin_params)
      log_info("Updated coin with ID #{@coin.id}")
      redirect_to @coin, notice: "Coin was successfully updated."
    else
      log_error("Failed to update coin with ID #{@coin.id}: #{@coin.errors.full_messages.join(', ')}")
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @coin.destroy
      log_info("Deleted coin with ID #{@coin.id}")
      redirect_to coins_path, notice: "Coin was successfully destroyed.", status: :see_other
    else
      log_error("Failed to delete coin with ID #{@coin.id}: #{@coin.errors.full_messages.join(', ')}")
      redirect_to @coin, alert: "Coin could not be deleted."
    end
  end

  private
    def set_coin
      @coin = Coin.find(params[:id])
    end

    def coin_params
      params.fetch(:coin, {})
    end
end
