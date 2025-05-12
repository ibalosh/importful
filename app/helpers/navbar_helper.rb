module NavbarHelper
  def role_span(type)
    color = (type == "admin") ? "bg-info" : "bg-warning"
    class_style = "badge #{color} text-white ms-2 bg-gradient"
    content_tag(:span, "#{type.downcase} user", class: class_style)
  end
end
