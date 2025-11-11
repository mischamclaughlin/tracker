module ApplicationHelper
  def nav_list_active?(path)
    'active' if current_page?(path)
  end
end
