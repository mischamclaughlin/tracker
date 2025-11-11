module PortfoliosHelper
  def total_portfolios_value(portfolios)
    portfolios.sum(&:fiat_balance)
  end

  def total_portfolios_invested(portfolios)
    portfolios.sum(&:total_invested)
  end

  def total_portfolios_profit_loss(portfolios)
    portfolios.sum(&:profit_loss)
  end

  def total_portfolios_profit_loss_percentage(portfolios)
    total_invested = total_portfolios_invested(portfolios)
    return 0 if total_invested.zero?
    
    ((total_portfolios_profit_loss(portfolios) / total_invested) * 100)
  end

  def pnl_value_class(value)
    if value.positive?
      'positive numeric'
    elsif value.negative?
      'negative numeric'
    else
      'neutral numeric'
    end
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
          concat(content_tag(:td, number_to_currency(portfolio.fiat_balance), class: 'numeric'))
          concat(content_tag(:td, number_to_currency(portfolio.total_invested), class: 'numeric'))
          concat(content_tag(:td, content_tag(:div, number_to_currency(portfolio.profit_loss), class: pnl_value_class(portfolio.profit_loss))))
          concat(content_tag(:td, content_tag(:div, "#{'%.2f' % portfolio.profit_loss_percentage}%", class: pnl_value_class(portfolio.profit_loss_percentage))))
          concat(content_tag(:td, link_to('View', portfolio_path(portfolio), class: 'btn btn-small')))
        end)
      end
    end
  end

  def display_portfolio_details(portfolio)
    content_tag(:table, class: 'portfolio-details-table') do
      concat(content_tag(:tr) do
        concat(content_tag(:th, 'Attribute'))
        concat(content_tag(:th, 'Value'))
      end)
      concat(content_tag(:tr) do
        concat(content_tag(:td, 'Portfolio Name'))
        concat(content_tag(:td, portfolio.portfolio_name))
      end)
      concat(content_tag(:tr) do
        concat(content_tag(:td, 'Fiat Balance'))
        concat(content_tag(:td, number_to_currency(portfolio.fiat_balance)))
      end)
      concat(content_tag(:tr) do
        concat(content_tag(:td, 'Total Invested'))
        concat(content_tag(:td, number_to_currency(portfolio.total_invested)))
      end)
      concat(content_tag(:tr) do
        concat(content_tag(:td, 'Profit/Loss'))
        concat(content_tag(:td, content_tag(:div, number_to_currency(portfolio.profit_loss), class: pnl_value_class(portfolio.profit_loss))))
      end)
      concat(content_tag(:tr) do
        concat(content_tag(:td, 'Profit/Loss Percentage'))
        concat(content_tag(:td, content_tag(:div, "#{'%.2f' % portfolio.profit_loss_percentage}%", class: pnl_value_class(portfolio.profit_loss_percentage))))
      end)
    end
  end
end
