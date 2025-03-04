class DataProcessorError < StandardError; end
class CsvDataProcessorError < DataProcessorError; end

# Simple wrapper for processing CSV files, with sensible defaults.
class CsvDataProcessor
  # @param options [Hash] options to pass to SmarterCSV, if not set, default options will be used
  def initialize(options: {})
    @options = options.merge(default_options)
  end

  def process(file)
    SmarterCSV.process(file, options) do |chunk|
      yield chunk if block_given?
    end
  rescue SmarterCSV::Error => e
    raise CsvDataProcessorError, e.message
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
      remove_empty_values: false,
      remove_empty_hashes: false,
      file_encoding: "bom|utf-8"
    }
  end
end
