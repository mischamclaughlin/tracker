module SortParamGuard
  extend ActiveSupport::Concern

  included do
    before_action :check_sort_params, only: [:index]
  end

  private

  def check_sort_params
    case controller_name
    when 'transactions'
      params_info = set_transaction_params
    when 'portfolios'
      params_info = set_portfolio_params
    when 'coins'
      params_info = set_coin_params
    else
      log_error("SortParamGuard: Unknown controller #{controller_name}")
      return
    end

    unless params[:sort_by].present?
      params[:sort_by] = params_info[:default_param]
      params[:dir] ||= 'desc'
      log_info("No sort parameter provided, defaulting to '#{params[:sort_by]}'")
      return
    end

    allowed_columns = params_info[:allowed_columns]
    unless allowed_columns.include?(params[:sort_by])
      log_info("Invalid sort parameter: #{params[:sort_by]}, reset to default '#{params_info[:default_param]}'")
      redirect_to send(params_info[:default_path], sort_by: params_info[:default_param]), alert: 'Invalid sort parameter.'
    end
  end

  def set_transaction_params
    default_param = 'time'
    default_path = :transactions_path
    { default_param: default_param, default_path: default_path, allowed_columns: Transaction::ALLOWED_COLUMNS }
  end

  def set_portfolio_params
    default_param = 'portfolio_name'
    default_path = :portfolios_path
    { default_param: default_param, default_path: default_path, allowed_columns: Portfolio::ALLOWED_COLUMNS }
  end

  def set_coin_params
    default_param = 'symbol'
    default_path = :coins_path
    { default_param: default_param, default_path: default_path, allowed_columns: Coin::ALLOWED_COLUMNS }
  end

  def switch_sort_direction(dir, sort_by)
    if sort_by == 'coin_name' || sort_by == 'symbol' || sort_by == 'portfolio_name'
      dir == 'asc' ? 'desc' : 'asc'
    end
  end
end
