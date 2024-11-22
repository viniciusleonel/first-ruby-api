class ValidateFileFormat

  def self.valid_file_format?(file_path)
    File.readlines(file_path).each_with_index do |line, index|
      begin
        stripped_line = line.strip
        raise "Line has invalid length: #{line.length} characters" unless stripped_line.length == 95
        valid_line_format?(stripped_line)
      rescue StandardError => e
        raise "Error in line #{index + 1}: #{e.message}"
      end
    end
  end

  def self.valid_line_format?(line)
    begin
      user_id = line[0..9].to_s.strip
      user_name = line[10..54].to_s.strip
      order_id = line[55..64].to_s.strip
      product_id = line[65..74].to_s.strip
      value = line[75..86].to_s.strip
      date = line[87..94].to_s.strip

      raise "Invalid user ID" unless valid_user_id?(user_id)
      raise "Invalid user name" unless valid_user_name?(user_name)
      raise "Invalid order ID" unless valid_order_id?(order_id)
      raise "Invalid product ID" unless valid_product_id?(product_id)
      raise "Invalid value" unless valid_value?(value)
      raise "Invalid date" unless valid_date?(date)

      true
    rescue StandardError => e
      raise "Error in line format: #{e.message}"
    end
  end

  def self.valid_user_id?(user_id)
    user_id.match?(/^\d{10}$/)
  end

  def self.valid_user_name?(user_name)
    sanitized_name = user_name.strip
    return false if sanitized_name.length > 45
    regex = /\A[a-zA-ZÀ-ÖØ-öø-ÿ'.\s]+\z/
    sanitized_name.match?(regex) && sanitized_name.split.any? { |name| name.length >= 3 }
  end

  def self.valid_order_id?(order_id)
    order_id.match?(/^\d{10}$/)
  end

  def self.valid_product_id?(product_id)
    product_id.match?(/^\d{10}$/)
  end

  def self.valid_numeric_field?(field, length)
    field.match?(/\A\d{#{length}}\z/)
  end

  def self.valid_value?(value)
    sanitized_value = value.strip
    sanitized_value.match?(/\A\d+\.\d{1,2}\z/)
  end

  def self.valid_date?(date)
    date.match?(/\A\d{8}\z/)
  end

end