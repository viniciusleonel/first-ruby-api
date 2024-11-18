require 'pg'
require 'date'
require 'async'

class FileProcessor
  def self.save_data_to_db
    connection = Database.connect

    Async do
      total_lines = `wc -l < challenge/data_1.txt`.to_i # Conta o número total de linhas no arquivo
      current_line = 0 # Contador para o progresso

      # Ler o arquivo
      File.foreach('challenge/data_1.txt') do |linha|
        user_id = linha[0, 10].strip.to_i
        name = linha[10, 45].strip
        order_id = linha[55, 10].strip.to_i
        product_id = linha[65, 10].strip.to_i
        value = linha[75, 12].strip.to_f
        date = Date.strptime(linha[87, 8].strip, '%Y%m%d')

        # Salvar o usuário
        connection.exec_params(
          "INSERT INTO users (user_id, name) VALUES ($1, $2) ON CONFLICT (user_id) DO NOTHING",
          [user_id, name]
        )

        # Salvar o pedido
        connection.exec_params(
          "INSERT INTO orders (order_id, user_id, total, date) VALUES ($1, $2, $3, $4) ON CONFLICT (order_id) DO NOTHING",
          [order_id, user_id, value, date]
        )

        # Salvar o produto
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
    ensure
      connection.close if connection
    end
  end
end
