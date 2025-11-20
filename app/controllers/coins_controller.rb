class CoinsController < ApplicationController
  include SortParamGuard

  before_action :set_coin, only: %i[ show edit update destroy ]
  before_action :set_coin_for_chart, only: %i[ chart_data ]

  def index
    log_info("Coin index accessed with params: #{params.inspect}")
    if params[:name] && !params[:name].strip.empty?
      normalise_name = params[:name].upcase.strip
      @coins = Coin.search(normalise_name).order_by_column(params[:sort_by], params[:dir])
      log_info("Searched coins by name: #{normalise_name}")
    else
      @coins = Coin.all.order_by_column(params[:sort_by], params[:dir])
      log_info("Fetched all coins")
      log_info("Sorted coins by #{params[:sort_by]}")
    end
  end

  def show
    log_info("Fetched coin: #{@coin.id}")
  rescue ActiveRecord::RecordNotFound
    log_error("Coin not found with id: #{params[:id]}")
    redirect_to coins_path, alert: "Coin not found."
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

  def chart_data
    to = Time.current
    from = case params[:range]
    when "24h" then to - 24.hours
    when "7d"  then to - 7.days
    when "30d" then to - 30.days
    when "90d" then to - 90.days
    else
             to - 1.year
    end

    series = Price.where(coin_id: @coin.id, recorded_at: from..to)
                  .order(:recorded_at)
                  .pluck(:recorded_at, :price)

    render json: series.map { |t, p| { x: t.iso8601, y: p.to_f } }
  end

  private

    def set_coin
      @coin = Coin.find(params[:id])
    end

    def set_coin_for_chart
      @coin = Coin.find(params[:id])
    end

    def coin_params
      params.fetch(:coin, {})
    end
end
