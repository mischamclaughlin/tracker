module ApplicationHelper
  def nav_list_active?(path)
    'active' if current_page?(path)
  end

  def nav_label(label, path)
    current_page?(path) ? "#{label}/" : label
  end
end
