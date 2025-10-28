module AssetsHelper
  def display_assets(assets)
    content_tag(:table, class: 'assets-table') do
      concat(content_tag(:tr) do
        concat(content_tag(:th, 'Name'))
        concat(content_tag(:th, 'Balance'))
        concat(content_tag(:th, 'View'))
      end)

      assets.each do |asset|
        concat(content_tag(:tr) do
          concat(content_tag(:td, asset.name))
          concat(content_tag(:td, number_to_currency(asset.balance)))
          concat(content_tag(:td, link_to('View', asset_path(asset))))
        end)
      end
    end
  end
end
