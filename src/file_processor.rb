require 'pg'
require 'date'

class FileProcessor

  def save_data_to_db(file_path)
    begin
      connection = Database.connect

      File.foreach(file_path) do |line|
        # Exemplo de como você pode separar os dados e construir a query
        user_id, name, total, date = parse_line(line) # Adapte para o formato dos seus dados
        connection.exec_params("INSERT INTO users (user_id, name) VALUES ($1, $2)", [user_id, name])

        # Inserir dados em 'orders' e 'products' conforme necessário
        order_id, value, product_id = parse_order_and_product(line)
        connection.exec_params("INSERT INTO orders (order_id, user_id, total, date) VALUES ($1, $2, $3, $4)",
                               [order_id, user_id, total, date])

        connection.exec_params("INSERT INTO products (product_id, order_id, value) VALUES ($1, $2, $3)",
                               [product_id, order_id, value])
      end

    rescue PG::Error => e
      puts "Erro ao processar os dados: #{e.message}"
    ensure
      connection.close if connection
    end
  end

end
