module SortParamGuard
  extend ActiveSupport::Concern

  included do
    before_action :check_sort_params, only: [:index]
  end

  private

  def check_sort_params
    default_param = controller_name == 'transactions' ? 'time' : 'balance_in_fiat'
    default_path = controller_name == 'transactions' ? :transactions_path : :assets_path
    unless params[:sort_by].present?
      params[:sort_by] = default_param
    end

    allowed_columns = controller_name == 'transactions' ? Transaction::ALLOWED_COLUMNS : Asset::ALLOWED_COLUMNS
    unless allowed_columns.include?(params[:sort_by])
      log_info("Invalid sort parameter: #{params[:sort_by]}, reset to default '#{default_param}'")
      redirect_to send(default_path, sort_by: default_param), alert: 'Invalid sort parameter.'
    end
  end
end
