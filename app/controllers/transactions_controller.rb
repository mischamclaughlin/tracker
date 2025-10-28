class TransactionsController < ApplicationController
  before_action :set_transaction, only: [:show, :edit, :update, :destroy]

  def index
    if params[:asset]
      normalise_asset = params[:asset].upcase.strip
      @transactions = Transaction.includes(:asset_record).search_by_asset(normalise_asset).order(asset: :asc, time: :desc)
      log_info("Searched transactions by asset: #{normalise_asset}")
    else
      @transactions = Transaction.includes(:asset_record).all.order(asset: :asc, time: :desc)
      log_info("Fetched all transactions")
    end
  end

  def show
    log_info("Viewing transaction with ID #{@transaction.id}")
  end

  def new
    @transaction = Transaction.new
    if params[:asset].present?
      @transaction.asset = params[:asset].upcase.strip
      log_info("Initialized new transaction for asset: #{@transaction.asset}")
    end
  end

  def create
    @transaction = Transaction.new(transaction_params)
    if @transaction.save
      log_info("Created transaction with ID #{@transaction.id}")
      redirect_to @transaction, notice: 'Transaction was successfully created.', status: :see_other
    else
      log_error("Failed to create transaction: #{@transaction.errors.full_messages.join(', ')}")
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @transaction.update(transaction_params)
      log_info("Updated transaction with ID #{@transaction.id}")
      redirect_to @transaction, notice: 'Transaction was successfully updated.'
    else
      log_error("Failed to update transaction with ID #{@transaction.id}: #{@transaction.errors.full_messages.join(', ')}")
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @transaction.destroy
      log_info("Deleted transaction with ID #{@transaction.id}")
      redirect_to transactions_path, notice: 'Transaction was successfully destroyed.', status: :see_other
    else
      log_error("Failed to delete transaction with ID #{@transaction.id}: #{@transaction.errors.full_messages.join(', ')}")
      redirect_to transactions_path, alert: 'Transaction could not be deleted.'
    end
  end

  private

  def set_transaction
    @transaction = Transaction.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    log_error("Transaction with ID #{params[:id]} not found.")
    redirect_to transactions_path, alert: 'Transaction not found.'
  end

  def transaction_params
    params.require(:transaction).permit(:asset, :action, :time, :memo, :amount)
  end
end
