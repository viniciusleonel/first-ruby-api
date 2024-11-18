class FileService
  def self.save_file(file, filename)
    # Defina a pasta de uploads, garantindo que exista
    uploads_folder = "uploads"  # Ou defina com o valor correto da sua configuração

    # Cria o diretório de uploads caso não exista
    Dir.mkdir(uploads_folder) unless Dir.exist?(uploads_folder)

    # Salva o arquivo na pasta de uploads
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

  def self.save_data_to_db(file_path)
    connection = Database.connect

    # Executar de forma assíncrona
    Async do
      # Abrir o arquivo para leitura
      File.open(file_path, 'r') do |file|
        total_lines = file.each_line.count # Conta o número total de linhas no arquivo
        file.rewind # Volta ao início do arquivo
        current_line = 0 # Contador para o progresso

        # Ler o arquivo linha por linha
        file.each_line do |linha|
          user_id = linha[0, 10].strip.to_i
          name = linha[10, 45].strip
          order_id = linha[55, 10].strip.to_i
          product_id = linha[65, 10].strip.to_i
          value = linha[75, 12].strip.to_f
          date = Date.strptime(linha[87, 8].strip, '%Y%m%d')

          # Inserir dados nas tabelas
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

          # Atualizar o progresso a cada 100 linhas processadas
          if current_line % 100 == 0
            puts "Processando linha #{current_line} de #{total_lines}..."
          end
        end

        puts "Processamento completo!"
      end
    ensure
      connection.close if connection
    end
  end
end
