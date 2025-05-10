module ImportsHelper
  def import_status_badge(status)
    badge_class = case status
    when "finished"   then "bg-success text-white"
    when "processing" then "text-dark pulse"
    when "failed"     then "bg-danger text-white"
    else "bg-secondary text-white"
    end

    content_tag(:span, status.capitalize, class: "badge #{badge_class}")
  end
end
