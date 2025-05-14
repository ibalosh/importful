include Pagy::Frontend
module ApplicationHelper
  def flash_class(level)
    case level.to_sym
    when :notice then "alert alert-success"
    when :alert then "alert alert-danger"
    else
      ""
    end
  end

  def active_nav_link(link)
    current_page?(link) ? "active" : ""
  end

  def number_or_dash(value, show)
    show ? value : "-"
  end
end
