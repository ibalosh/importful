require "bigdecimal"


# Helper class to format hash values

class HashValueFormatter
  def format(data, transformations)
    data.each_with_object({}) do |(key, value), formatted_data|
      methods = transformations[key] || []
      formatted_data[key] = apply_transformations(value, methods)
    end
  end

  private

  def apply_transformations(value, methods)
    methods.reduce(value) { |result, method| send(method, result) }
  end

  def clean_string(value)
    value.to_s.strip
  end

  def capitalize_string(name)
    return nil if name.blank?
    name.strip.capitalize
  end

  def normalize_string(email)
    email.to_s.strip.downcase
  end

  # Normalizes a URL by ensuring it includes a protocol (http:// or https://).
  #
  # @param url [String] The URL to normalize.
  # @return [String] The normalized URL.
  def normalize_url(url)
    return "" if url.blank?
    url = url.strip
    url = url.downcase
    url = "http://#{url}" unless url.match?(/\Ahttp(s)?:\/\//)
    url
  end

  # Normalizes a numeric value, handling different decimal/thousands separators.
  #
  # @param value [String, Numeric] The value to normalize.
  # @return [BigDecimal, 0] The normalized number or nil if invalid.
  def normalize_number(value)
    return BigDecimal(0) if value.to_s.blank?

    value = value.to_s.strip

    # Detect if comma or dot is used more frequently as thousands/decimal separator
    comma_count = value.count(",")
    dot_count = value.count(".")

    # If both are present, assume **comma is thousands separator** and **dot is decimal**
    # else if only commas, assume **European format** where comma is decimal
    if comma_count > 0 && dot_count > 0
      value.gsub!(",", "")
    elsif comma_count > 0 && dot_count == 0
      value.gsub!(",", ".")
    end

    # Remove any spaces (e.g., "1 234 567,89")
    value.gsub!(/\s+/, "")
    BigDecimal(value) rescue 0
  end
end
