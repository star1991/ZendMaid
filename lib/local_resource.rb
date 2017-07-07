class LocalResource
  attr_reader :uri
  def initialize(uri)
    @uri = uri
  end
  def file
    @file ||= Tempfile.new(tmp_filename, tmp_folder, encoding: encoding).tap do |f|
      io.rewind
      f.write(io.read)
      f.close
    end
  end
  def io
    @io ||= uri.open
  end
  def encoding
    io.rewind
    io.read.encoding
  end
  def tmp_filename
    [
      Pathname.new(uri.path).basename.to_s,
      Pathname.new(uri.path).extname.to_s
    ]
  end
  def tmp_folder
    # If we're using Rails:
    Rails.root.join('tmp').to_s
    # Otherwise:
    # '/wherever/you/want'
  end

  def self.local_resource_from_url(url)
    LocalResource.new(URI.parse(url))
  end
end