json.extract! portfolio, :id, :name, :balance_fiat, :balance_asset, :created_at, :updated_at
json.url portfolio_url(portfolio, format: :json)
