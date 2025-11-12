class TransactionsController < ApplicationController
  include SortParamGuard

  before_action :set_transaction, only: [:show, :edit, :update, :destroy]

  def index
    log_info("Transaction index accessed with params: #{params.inspect}")
    if params[:name] && !params[:name].strip.empty?
      normalise_name = params[:name].upcase.strip
      @transactions = current_user.transactions.includes(:coin, :portfolio).search(normalise_name).order_by_column(params[:sort_by], params[:dir])
      log_info("Searched transactions by asset: #{normalise_name}")
    else
      @transactions = current_user.transactions.all.order_by_column(params[:sort_by], params[:dir])
      log_info("Fetched all transactions")
      log_info("Sorted transactions by #{params[:sort_by]}")
    end
  end
  
  def show
    log_info("Viewing transaction with ID #{@transaction.id}")
  rescue ActiveRecord::RecordNotFound
    log_error("Transaction not found with id: #{params[:id]}")
    redirect_to transactions_path, alert: 'Transaction not found.'
  end

  def new
    @transaction = Transaction.new
    if params[:asset].present?
      @transaction.asset = params[:asset].upcase.strip
      log_info("Initialized new transaction for asset: #{@transaction.asset}")
    end
  end

  def edit
  end

  def create
    @transaction = Transaction.new(transaction_params)
    log_info("Transaction Params: #{transaction_params.inspect}")

    if @transaction.save
      ref_path = URI.parse(request.referer).path rescue nil
      if ref_path == quick_add_path
        redirect_to quick_add_path(transaction: @transaction), notice: "Transaction created.", status: :see_other
      else
        redirect_to @transactions, notice: "Transaction created.", status: :see_other
      end
    else
      log_error("Failed to create transaction: #{@transaction.errors.full_messages.join(', ')}")
      render :new, status: :unprocessable_entity
    end
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
      redirect_to @transaction, alert: 'Transaction could not be deleted.'
    end
  end

  private

  def set_transaction
    @transaction = current_user.transactions.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    log_error("Transaction with ID #{params[:id]} not found.")
    redirect_to transactions_path, alert: 'Transaction not found.'
  end

  def transaction_params
    params.require(:transaction).permit(:coin_identifier, :portfolio_identifier, :action, :time, :memo, :fiat_amount, :coin_amount)
  end
end
