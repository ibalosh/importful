class AffiliateImport
  def self.data_formatting_details
    {
      merchant_slug: [ :clean_string ],
      first_name: [ :clean_string, :capitalize_string ],
      last_name: [ :clean_string, :capitalize_string ],
      email: [ :clean_string, :normalize_string ],
      website_url: [ :clean_string, :normalize_url ],
      commissions_total: [ :normalize_number ]
    }
  end

  def self.required_headers
    %i[merchant_slug first_name last_name email website_url commissions_total]
  end

  def self.data_processor(file)
    CsvDataProcessor.new(file, options: { required_keys: AffiliateImport.required_headers })
  end
end
