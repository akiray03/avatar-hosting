# coding: utf-8

class Avatar
  include AvatarConfig

  def self.create form_object
    filename = form_object[:filename]
    tempfile = form_object[:tempfile]
    data     = tempfile.read
    email    = "%10d_%05d@%s" % [Time.now.to_i, $$, EMAIL_DOMAIN]
    extname  = File.extname(filename).sub('.', '')

    begin
      image = Magick::ImageList.new tempfile.path
      unless FILE_TYPE.include?(image.format.to_s.downcase)
        return nil
      end
    rescue => e
      return nil
    end

    self.new email: email, extname: extname, data: data, autosave: true
  end

  def self.find key
    self.find_by_hash key
  end

  def self.find_by_hash hash
    if hash.nil? or hash.class != String or (not File.exist? dirpath(hash))
      return nil
    end

    original = Dir.glob(File.join dirpath(hash), 'original.*').first
    extname  = File.extname(original)

    self.new hash: hash, extname: extname
  end

  def self.find_by_email email
    if email.nil? or email.class != String
      return nil
    end

    obj = find_by_hash hash(email)
    return nil  unless obj
    obj.email = email

    obj
  end

  def initialize email: nil, hash: nil, extname: nil, data: nil, autosave: false
    @email   = email
    @hash    = hash
    @extname = extname.sub('.', '').downcase if extname
    @data    = data if data

    if @email.nil? && @hash.nil?
      raise ArgumentError
    end
    @hash = self.class.hash @email  if @hash.nil?

    if autosave
      save
    end
  end
  attr_accessor :email, :hash, :extname

  def image_path size: nil, type: nil
    File.join(AVATAR_PREFIX, hash)
  end

  def original_filepath
    filepath
  end

  def filepath size: nil, type: nil, autoresize: false
    return nil  unless hash
    path = File.join(dirpath(hash), filename(size: size, type: type))
    if (not File.exist? path) && autoresize
      resize size: size, type: type
    end

    path
  end

  def resize size: nil, type: nil
    image = Magick::ImageList.new original_filepath
    if size
      image.resize_to_fill!(size, size)
    end
    image.write(filepath size: size, type: type)
  end

  def dirpath hash
    self.class.dirpath hash
  end

  def filename size: nil, type: nil
    size = 'original' if size.nil?
    type = extname    if type.nil?

    "#{size}.#{type}"
  end

  def save data = nil
    write_data = data ? data : @data
    if write_data
      FileUtils.mkdir_p(File.dirname filepath)
      File.open(filepath, 'wb') do |fp|
        fp.write write_data
      end
      return self
    end
    nil
  end

  def self.hash email
    email ? Digest::MD5.hexdigest(email.to_s.downcase) : nil
  end

  def self.dirpath hash
    File.join(DATA_DIR, hash[-1], hash[-2], hash)
  end
end
