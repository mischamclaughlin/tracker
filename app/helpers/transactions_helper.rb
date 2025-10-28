module TransactionsHelper
  def display_transactions(transactions)
    content_tag(:table, class: 'transactions-table') do
      concat(content_tag(:tr) do
        concat(content_tag(:th, 'Asset'))
        concat(content_tag(:th, 'Action'))
        concat(content_tag(:th, 'Date'))
        concat(content_tag(:th, 'Time'))
        concat(content_tag(:th, 'Memo'))
        concat(content_tag(:th, 'Amount'))
        concat(content_tag(:th, 'View'))
      end)

      transactions.each do |transaction|
        concat(content_tag(:tr) do
          concat(content_tag(:td, transaction.asset))
          concat(content_tag(:td, transaction.action, style: "background: #{transaction.action == 'buy' ? 'green' : 'red'}"))
          concat(content_tag(:td, transaction.time.strftime('%Y-%m-%d')))
          concat(content_tag(:td, transaction.time.strftime('%H:%M')))
          concat(content_tag(:td, transaction.memo))
          concat(content_tag(:td, number_to_currency(transaction.amount)))
          concat(content_tag(:td, link_to('View', transaction_path(transaction))))
        end)
      end
    end
  end
end
