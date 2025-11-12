class PortfoliosController < ApplicationController
  include SortParamGuard

  before_action :set_portfolio, only: %i[ show edit update destroy ]

  def index
    log_info("Portfolio index accessed with params: #{params.inspect}")
    if params[:name] && !params[:name].strip.empty?
      normalise_name = params[:name].upcase.strip
      @portfolios = current_user.portfolios.search_by_portfolio_name(normalise_name).order_by_column(params[:sort_by], params[:dir])
      log_info("Searched portfolios by name: #{normalise_name}")
    else
      @portfolios = current_user.portfolios.all.order_by_column(params[:sort_by], params[:dir])
      log_info("Fetched all portfolios")
      log_info("Sorted portfolios by #{params[:sort_by]}")
    end
  end

  def show
    log_info("Viewing portfolio: #{@portfolio.portfolio_name}")
  rescue ActiveRecord::RecordNotFound
    log_error("Portfolio not found with id: #{params[:id]}")
    redirect_to portfolios_path, alert: 'Portfolio not found.'
  end

  def new
    @portfolio = Portfolio.new
  end

  def edit
  end

  def create
    @portfolio = current_user.portfolios.new(portfolio_params)
    log_info("Portfolio Params: #{portfolio_params.inspect}")

    if @portfolio.save
      log_info("Created portfolio with ID #{@portfolio.id}")
      redirect_to @portfolio, notice: "Portfolio was successfully created.", status: :see_other
    else
      log_error("Failed to create portfolio: #{@portfolio.errors.full_messages.join(', ')}")
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @portfolio.update(portfolio_params)
      log_info("Updated portfolio with ID #{@portfolio.id}")
      redirect_to @portfolio, notice: "Portfolio was successfully updated."
    else
      log_error("Failed to update portfolio with ID #{@portfolio.id}: #{@portfolio.errors.full_messages.join(', ')}")
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @portfolio.destroy
      log_info("Deleted portfolio with ID #{@portfolio.id}")
      redirect_to portfolios_path, notice: "Portfolio was successfully destroyed.", status: :see_other
    else
      log_error("Failed to delete portfolio with ID #{@portfolio.id}: #{@portfolio.errors.full_messages.join(', ')}")
      redirect_to @portfolio, alert: "Portfolio could not be deleted."
    end
  end

  def recalculate_balance
    @portfolio.recalculate_balance!
    log_info("Recalculated balance for portfolio: #{@portfolio.portfolio_name}")
    redirect_to portfolio_path(@portfolio), notice: "#{@portfolio.portfolio_name} balance recalculated."
  rescue ActiveRecord::RecordNotFound
    log_error("Portfolio not found with id: #{params[:id]} for balance recalculation")
    redirect_to portfolios_path, alert: 'Portfolio not found.'
  end

  private

    def set_portfolio
      @portfolio = current_user.portfolios.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      log_error("Portfolio not found with id: #{params[:id]}")
      redirect_to portfolios_path, alert: 'Portfolio not found.'
    end

    def portfolio_params
      params.require(:portfolio).permit(:portfolio_name, :description, :balance, :total_invested, :profit_loss, :profit_loss_percentage)
    end
end
