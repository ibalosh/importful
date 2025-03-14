# This class is responsible for transforming the data from one key to another key
# and removing the old key from the data.
# For example, we can transform the data from the key :merchant_slug to the key :merchant_id
# and remove the :merchant_slug key from the data.
class DataTransformer
  def initialize(from_key:, to_key:)
    @from_key = from_key
    @to_key = to_key
  end

  def transform(data, from_to_key_map)
    data.map do |row|
      row[@to_key] = from_to_key_map[row[@from_key]] || -1
      row.delete(@from_key)
      row
    end
  end
end
