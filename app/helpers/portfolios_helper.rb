module PortfoliosHelper
  def total_portfolios_value(portfolios)
    portfolios.sum(&:current_value)
  end

  def total_portfolios_invested(portfolios)
    portfolios.sum(&:total_fiat_invested)
  end

  def total_portfolios_profit_loss(portfolios)
    portfolios.sum(&:profit_loss)
  end

  def total_portfolios_profit_loss_percentage(portfolios)
    total_invested = total_portfolios_invested(portfolios)
    return 0 if total_invested.zero?
    
    ((total_portfolios_profit_loss(portfolios) / total_invested) * 100)
  end

  def display_portfolios(portfolios)
    content_tag(:table, class: 'portfolios-table') do
      concat(content_tag(:tr) do
        concat(content_tag(:th, 'Portfolio'))
        concat(content_tag(:th, 'Balance'))
        concat(content_tag(:th, 'Invested'))
        concat(content_tag(:th, 'Profit'))
        concat(content_tag(:th, 'Profit %'))
        concat(content_tag(:th, 'Actions'))
      end)
      unless params[:name]
        concat(content_tag(:tr) do
          concat(content_tag(:td, 'Main', class: 'main'))
          concat(content_tag(:td, number_to_currency(total_portfolios_value(portfolios)), class: 'numeric main'))
          concat(content_tag(:td, number_to_currency(total_portfolios_invested(portfolios)), class: 'numeric main'))
          concat(content_tag(:td, content_tag(:div, number_to_currency(total_portfolios_profit_loss(portfolios)), class: total_portfolios_profit_loss(portfolios).positive? ? 'main positive numeric' : 'main negative numeric')))
          concat(content_tag(:td, content_tag(:div, "#{'%.2f' % total_portfolios_profit_loss_percentage(portfolios)}%", class: total_portfolios_profit_loss_percentage(portfolios).positive? ? 'main positive numeric' : 'main negative numeric')))
          concat(content_tag(:td, '---', class: 'main'))
        end)
        concat(content_tag(:tr) do
          concat(content_tag(:td, '', colspan: 6, class: 'spacer-row'))
        end)
      end
      portfolios.each do |portfolio|
        concat(content_tag(:tr) do
          concat(content_tag(:td, portfolio.portfolio_name))
          concat(content_tag(:td, number_to_currency(portfolio.balance), class: 'numeric'))
          concat(content_tag(:td, number_to_currency(portfolio.total_invested), class: 'numeric'))
          concat(content_tag(:td, content_tag(:div, number_to_currency(portfolio.profit_loss), class: portfolio.profit_loss.positive? ? 'positive numeric' : 'negative numeric')))
          concat(content_tag(:td, content_tag(:div, "#{'%.2f' % portfolio.profit_loss_percentage}%", class: portfolio.profit_loss_percentage.positive? ? 'positive numeric' : 'negative numeric')))
          concat(content_tag(:td, link_to('View', portfolio_path(portfolio))))
        end)
      end
    end
  end
end
