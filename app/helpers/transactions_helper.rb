module TransactionsHelper
  def display_transactions(transactions)
    content_tag(:table, class: 'transactions-table') do
      concat(content_tag(:tr) do
        concat(content_tag(:th, 'Coin'))
        concat(content_tag(:th, 'Portfolio'))
        concat(content_tag(:th, 'Action'))
        concat(content_tag(:th, 'Date'))
        concat(content_tag(:th, 'Time'))
        concat(content_tag(:th, 'Fiat'))
        concat(content_tag(:th, 'Coin'))
        concat(content_tag(:th, 'Price'))
        concat(content_tag(:th, 'View'))
      end)

      transactions.each do |transaction|
        concat(content_tag(:tr) do
          concat(content_tag(:td, transaction.coin_information&.symbol.upcase || 'N/A'))
          concat(content_tag(:td, transaction.portfolio_information&.portfolio_name || 'N/A'))
          concat(content_tag(:td, content_tag(:div, transaction.action, class: "#{transaction.action == 'buy' ? 'positive' : 'negative'}")))
          concat(content_tag(:td, transaction.time.strftime('%d/%m/%Y')))
          concat(content_tag(:td, transaction.time.strftime('%H:%M')))
          concat(content_tag(:td, number_to_currency(transaction.fiat_amount), class: 'numeric'))
          concat(content_tag(:td, transaction.coin_amount.round(10), class: 'numeric'))
          concat(content_tag(:td, number_to_currency(transaction.coin_price_at(transaction.time)&.price), class: 'numeric'))
          concat(content_tag(:td, link_to('View', transaction_path(transaction))))
        end)
      end
    end
  end
end
