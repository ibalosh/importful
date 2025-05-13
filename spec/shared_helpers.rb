module SharedHelpers
  def create_temp_file(filename:, content:)
    file = Tempfile.new(filename)
    file.write(content)
    file.rewind
    file
  end

  def create_temp_binary_file(filename:, content: Array.new(1024) { rand(0..255).chr }.join.force_encoding("BINARY"))
    file = Tempfile.new(filename)
    file.binmode
    file.write(content)
    file.rewind
    file
  end
end
