# Simple wrapper for processing CSV files, with sensible defaults.
class CsvDataProcessor
  # @param file [String] path to the CSV file
  # @param options [Hash] options to pass to SmarterCSV, if not set, default options will be used
  def initialize(file, options: {})
    @file = file
    @options = options.merge(default_options)
  end

  def process
    SmarterCSV.process(file, options) do |chunk|
      yield chunk if block_given?
    end
  end

  private

  attr_reader :file, :options

  # When processing data from a CSV file, these settings allow for the data to be processed in chunks
  # check for headers in the file, transform the headers, etc..
  # @return [Hash]
  def default_options
    {
      headers_in_file: true,
      header_transformations: [ :downcase, :strip ],
      chunk_size: 500,
      remove_unmapped_keys: true,
      remove_empty_values: true,
      file_encoding: "bom|utf-8"
    }
  end
end
