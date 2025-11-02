module TransactionsHelper
  def display_transactions(transactions)
    content_tag(:table, class: 'transactions-table') do
      concat(content_tag(:tr) do
        concat(content_tag(:th, 'Asset'))
        concat(content_tag(:th, 'Action'))
        concat(content_tag(:th, 'Date'))
        concat(content_tag(:th, 'Time'))
        concat(content_tag(:th, 'Memo'))
        concat(content_tag(:th, 'Asset Amount'))
        concat(content_tag(:th, 'Fiat Amount'))
        concat(content_tag(:th, 'Price'))
        concat(content_tag(:th, 'View'))
      end)

      transactions.each do |transaction|
        concat(content_tag(:tr) do
          concat(content_tag(:td, transaction.asset))
          concat(content_tag(:td, content_tag(:div, transaction.action, class: "#{transaction.action == 'buy' ? 'positive' : 'negative'}")))
          concat(content_tag(:td, transaction.time.strftime('%d/%m/%Y')))
          concat(content_tag(:td, transaction.time.strftime('%H:%M')))
          concat(content_tag(:td, transaction.memo))
          concat(content_tag(:td, transaction.amount, class: 'numeric'))
          concat(content_tag(:td, number_to_currency(transaction.fiat), class: 'numeric'))
          concat(content_tag(:td, number_to_currency(transaction.price_at_time), class: 'numeric'))
          concat(content_tag(:td, link_to('View', transaction_path(transaction))))
        end)
      end
    end
  end
end
