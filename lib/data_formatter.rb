require "bigdecimal"

# Formats data according to the provided transformations.
# The transformations are a hash where the key is the field name and the value is an array of
# methods to apply to the field.
# For example, transformation details could look like this:
#
# {
#   first_name: [ :clean_string, :capitalize_string ]
#   last_name: [ :clean_string, :capitalize_string ]
# }
#
# which would capitalize the first and last name and strip whitespace.
class DataFormatter
  attr_accessor :transformations
  def initialize(transformations)
    @transformations = transformations
  end

  # @param data [Array<Hash>, Hash] - data to format.
  def format(data)
    if data.is_a?(Array)
      data.map { |h| format_hash_object(h) }
    else
      format_hash_object(data)
    end
  end

  private

  # @param hash [Hash] - hash object to format.
  def format_hash_object(hash)
    hash.each_with_object({}) do |(key, value), formatted_data|
      methods = transformations[key] || []
      formatted_data[key] = apply_transformations(value, methods)
    end
  end

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

  # @return [String] The normalized string or an empty string if invalid.
  def normalize_string(string)
    string.to_s.strip.downcase
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
