module SharedHelpers
  def create_temp_file(filename:, content:)
    file = Tempfile.new(filename)
    file.write(content)
    file.rewind
    file
  end
end
