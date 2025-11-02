module AssetsHelper
  def display_assets(assets)
    content_tag(:table, class: 'assets-table') do
      concat(content_tag(:tr) do
        concat(content_tag(:th, 'Name'))
        concat(content_tag(:th, 'Asset Total'))
        concat(content_tag(:th, 'Fiat Balance'))
        concat(content_tag(:th, 'Current Price'))
        concat(content_tag(:th, 'Total P&L'))
        concat(content_tag(:th, 'View'))
      end)

      assets.each do |asset|
        concat(content_tag(:tr) do
          concat(content_tag(:td, asset.name))
          concat(content_tag(:td, format_crypto_amount(asset.balance), class: "numeric"))
          concat(content_tag(:td, number_to_currency(asset.balance_in_fiat), class: "numeric"))
          concat(content_tag(:td, number_to_currency(asset.current_price&.price || 0), class: "numeric"))
          concat(content_tag(:td, content_tag(:div, display_pnl(asset.total_pnl), class: "#{asset.total_pnl.positive? ? 'positive' : 'negative'}")))
          concat(content_tag(:td, link_to('View', asset_path(asset))))
        end)
      end
    end
  end

  def format_crypto_amount(amount, precision: 8)
    formatted = number_with_precision(amount, precision: precision, strip_insignificant_zeros: true)
    formatted
  end

  def display_pnl(amount)
    return content_tag(:p, "$0.00", class: 'pnl-neutral') if amount.zero?

    css_class = amount.positive? ? 'pnl-positive' : 'pnl-negative'
    content_tag(:p, number_to_currency(amount), class: css_class)
  end

  def display_pnl_percentage(percentage)
    return content_tag(:p, "0.00%", class: 'pnl-neutral') if percentage.zero?

    css_class = percentage.positive? ? 'pnl-positive' : 'pnl-negative'
    content_tag(:p, "#{percentage.round(2)}%", class: css_class)
  end
end
