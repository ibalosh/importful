module NavbarHelper
  def role_span(type)
    color = (type == "admin") ? "bg-info" : "bg-warning"
    class_style = "badge #{color} text-white ms-2 bg-gradient"
    label = type == "admin" ? "backdoor admin user" : "regular user"
    content_tag(:span, label, class: class_style)
  end
end
