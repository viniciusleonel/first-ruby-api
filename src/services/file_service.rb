class FileService
  def self.save_file(file, filename)
    uploads_folder = "uploads"

    Dir.mkdir(uploads_folder) unless Dir.exist?(uploads_folder)

    filepath = "#{uploads_folder}/#{filename}"
    if File.exist?(filepath)
      raise "Erro: O arquivo '#{filename}' já existe na pasta de uploads."
    end

    File.open("#{uploads_folder}/#{filename}", 'wb') do |f|
      f.write(file.read)
    end

    puts "Arquivo '#{filename}' salvo com sucesso em #{uploads_folder}/"

    filepath
  end

  def self.delete_file(filename)
    uploads_folder = "uploads"
    filepath = "#{uploads_folder}/#{filename}"

    if File.exist?(filepath)
      File.delete(filepath)
      puts "Arquivo '#{filename}' deletado com sucesso."
    else
      puts "Erro: O arquivo '#{filename}' não foi encontrado."
    end
  end


  def self.save_data_to_db(file_path, filename)
    connection = Database.connect

    Async do
      File.open(file_path, 'r') do |file|
        total_lines = file.each_line.count
        file.rewind
        current_line = 0

        file.each_line do |linha|
          user_id = linha[0, 10].strip.to_i
          name = linha[10, 45].strip
          order_id = linha[55, 10].strip.to_i
          product_id = linha[65, 10].strip.to_i
          value = linha[75, 12].strip.to_f
          date = Date.strptime(linha[87, 8].strip, '%Y%m%d')

          connection.exec_params(
            "INSERT INTO users (user_id, name) VALUES ($1, $2) ON CONFLICT (user_id) DO NOTHING",
            [user_id, name]
          )

          connection.exec_params(
            "INSERT INTO orders (order_id, user_id, total, date) VALUES ($1, $2, $3, $4) ON CONFLICT (order_id) DO NOTHING",
            [order_id, user_id, value, date]
          )

          connection.exec_params(
            "INSERT INTO products (product_id, order_id, value) VALUES ($1, $2, $3) ON CONFLICT (product_id) DO NOTHING",
            [product_id, order_id, value]
          )

          current_line += 1

          if current_line % 100 == 0
            puts "Processando linha #{current_line} de #{total_lines}..."
          end
        end

        puts "Processamento completo!"

        delete_file(filename)
      end
    ensure
      connection.close if connection
    end
  end
end
