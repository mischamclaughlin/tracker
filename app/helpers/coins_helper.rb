module CoinsHelper
  def display_coins(coins)
    content_tag(:table, class: 'coins-table') do
      concat(content_tag(:tr) do
        concat(content_tag(:th, 'Symbol'))
        concat(content_tag(:th, 'Name'))
        concat(content_tag(:th, 'Fiat'))
        concat(content_tag(:th, 'Coin'))
        concat(content_tag(:th, 'Price'))
        # concat(content_tag(:th, 'Market Cap'))
        # concat(content_tag(:th, 'Price'))
        # concat(content_tag(:th, '24h Volume'))
        # concat(content_tag(:th, 'Change (24h)'))
      end)
      coins.each do |coin|
        concat(content_tag(:tr) do
          concat(content_tag(:td, coin.symbol.upcase))
          concat(content_tag(:td, coin.coin_name))
          concat(content_tag(:td, number_to_currency(coin.fiat_balance), class: 'numeric'))
          concat(content_tag(:td, "#{'%.8f' % coin.coin_balance}", class: 'numeric'))
          concat(content_tag(:td, number_to_currency(coin.latest_price), class: 'numeric'))
          # concat(content_tag(:td, "#{'%.2f' % number_to_currency(coin.market_cap)}", class: 'numeric'))
          # concat(content_tag(:td, "#{'%.2f' % number_to_currency(coin.current_price)}", class: 'numeric'))
          # concat(content_tag(:td, "#{'%.2f' % number_to_currency(coin.volume_24h)}", class: 'numeric'))
          # change_class = coin.change_24h >= 0 ? 'positive' : 'negative'
          # concat(content_tag(:td, content_tag(:div, "#{coin.change_24h.round(2)}%", class: change_class)))
        end)
      end
    end
  end
end
