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
          concat(content_tag(:td, "#{'%.8f' % transaction.coin_amount}", class: 'numeric'))
          concat(content_tag(:td, number_to_currency(transaction.coin_price_at(transaction.time)&.price), class: 'numeric'))
          concat(content_tag(:td, link_to('View', transaction_path(transaction))))
        end)
      end
    end
  end

  def display_transaction_details(transaction)
    content_tag(:table, class: 'transaction-details-table') do
      concat(content_tag(:tr) do
        concat(content_tag(:th, 'Attribute'))
        concat(content_tag(:th, 'Value'))
      end)
      concat(content_tag(:tr) do
        concat(content_tag(:td, 'Coin'))
        concat(content_tag(:td, transaction.coin_information&.symbol.upcase || 'N/A'))
      end)
      concat(content_tag(:tr) do
        concat(content_tag(:td, 'Portfolio'))
        concat(content_tag(:td, transaction.portfolio_information&.portfolio_name || 'N/A'))
      end)
      concat(content_tag(:tr) do
        concat(content_tag(:td, 'Action'))
        concat(content_tag(:td, transaction.action))
      end)
      concat(content_tag(:tr) do
        concat(content_tag(:td, 'Date'))
        concat(content_tag(:td, transaction.time.strftime('%d/%m/%Y')))
      end)
      concat(content_tag(:tr) do
        concat(content_tag(:td, 'Time'))
        concat(content_tag(:td, transaction.time.strftime('%H:%M:%S')))
      end)
      concat(content_tag(:tr) do
        concat(content_tag(:td, 'Fiat Amount'))
        concat(content_tag(:td, number_to_currency(transaction.fiat_amount)))
      end)
      concat(content_tag(:tr) do
        concat(content_tag(:td, 'Coin Amount'))
        concat(content_tag(:td, "#{'%.8f' % transaction.coin_amount}"))
      end)
      concat(content_tag(:tr) do
        concat(content_tag(:td, 'Price at Time'))
        price_at_time = transaction.coin_price_at(transaction.time)&.price
        concat(content_tag(:td, price_at_time ? number_to_currency(price_at_time) : 'N/A'))
      end)
    end
  end
end
