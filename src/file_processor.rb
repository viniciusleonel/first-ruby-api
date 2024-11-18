require 'pg'
require 'date'
require 'async'

class FileProcessor
  def self.save_data_to_db(file_path)
    connection = Database.connect

    Async do
      File.open(file_path, 'r') do |file|
        total_lines = file.each_line.count  # Conta o número total de linhas no arquivo
        file.rewind
        current_line = 0
        batch_size = 100  # Processa em lotes

        file.each_line.each_slice(batch_size) do |lines_batch|
          # Processar as linhas em lote
          lines_batch.each do |linha|
            user_id = linha[0, 10].strip.to_i
            name = linha[10, 45].strip
            order_id = linha[55, 10].strip.to_i
            product_id = linha[65, 10].strip.to_i
            value = linha[75, 12].strip.to_f
            date = Date.strptime(linha[87, 8].strip, '%Y%m%d')

            # Inserir os dados no banco de dados
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
          end

          # Atualizar o progresso
          puts "Processando batch de #{current_line} de #{total_lines}..."
        end

        puts "Processamento completo!"
      end
    ensure
      connection.close if connection
    end
  end
end

