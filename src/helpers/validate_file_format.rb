class ValidateFileFormat

  def self.valid_file_format?(file_path)
    File.readlines(file_path).all? do |line|
      valid_line_format?(line.strip)
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

      valid_user_id?(user_id)
      valid_user_name?(user_name)
      valid_order_id?(order_id)
      valid_product_id?(product_id)
      valid_value?(value)
      valid_date?(date)

    rescue => e
      raise "Error processing file, invalid format!"
    end
  end

  def self.valid_user_id?(user_id)
    user_id.match?(/^\d{10}$/) # 10 dígitos numéricos
  end

  def self.valid_user_name?(user_name)
    user_name.length <= 45 && user_name.strip == user_name # Máximo de 45 caracteres, sem espaços à esquerda
  end

  def self.valid_order_id?(order_id)
    order_id.match?(/^\d{10}$/) # 10 dígitos numéricos
  end

  def self.valid_product_id?(product_id)
    product_id.match?(/^\d{10}$/) # 10 dígitos numéricos
  end

  def self.valid_numeric_field?(field, length)
    field.match?(/\A\d{#{length}}\z/) # Verifica se é numérico e tem o tamanho correto
  end

  def self.valid_value?(value)
    value.match?(/\A\d{10}\.\d{2}\z/) # Verifica o formato decimal (10 inteiros e 2 decimais)
  end

  def self.valid_date?(date)
    date.match?(/\A\d{8}\z/) # Verifica o formato de data (yyyymmdd)
  end

end