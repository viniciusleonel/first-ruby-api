require 'async'

class FileService
  def self.save_file(file, filename)
    uploads_folder = "uploads"

    Dir.mkdir(uploads_folder) unless Dir.exist?(uploads_folder)

    filepath = "#{uploads_folder}/#{filename}"
    # if File.exist?(filepath)
    #   raise "Erro: O arquivo '#{filename}' já existe na pasta de uploads."
    # end

    File.open(filepath, 'wb') do |f|
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

  def self.process_file(file_path)
    users = {}

    File.open(file_path, 'r') do |file|
      file.each_line do |linha|
        user_id = linha[0, 10].strip.to_i
        name = linha[10, 45].strip
        order_id = linha[55, 10].strip.to_i
        product_id = linha[65, 10].strip.to_i
        value = linha[75, 12].strip.to_f
        date = Date.strptime(linha[87, 8].strip, '%Y%m%d')

        users[user_id] ||= {
          user_id: user_id,
          name: name,
          orders: []
        }

        order = users[user_id][:orders].find { |o| o.order_id == order_id }
        unless order
          order = Order.new(order_id, value, date.to_s)
          users[user_id][:orders] << order
        end

        order.add_product(
          {
            product_id: product_id,
            value: value
          })
      end
    end

    users.values.map do |user|
      {
        user_id: user[:user_id],
        name: user[:name],
        orders: user[:orders].map do |order|
          {
            order_id: order.order_id,
            total: order.total,
            date: order.date,
            products: order.products
          }
        end
      }
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

          save_user(connection, name, user_id)
          save_order_with_products(connection, order_id, user_id, value, date, product_id, value)

          current_line += 1

          if current_line % 100 == 0
            puts "Processando linha #{current_line} de #{total_lines}..."
          end
        end

        puts "Processamento completo!"
      end
    ensure
      delete_file(filename)
      connection.close if connection
    end
  end

  private

  def self.save_order_with_products(connection, order_id, user_id, total_value, date, product_id, value)
    # Recuperar a ordem existente (se houver) e adicionar o novo produto
    existing_order = connection.exec_params(
      "SELECT products FROM orders WHERE order_id = $1", [order_id]
    ).first

    # Se a ordem existir, recuperar os produtos já salvos; caso contrário, começar uma nova lista de produtos
    products = existing_order ? JSON.parse(existing_order['products']) : []

    # Adicionar o novo produto à lista de produtos, mesmo que o product_id já exista
    products << { "product_id" => product_id, "value" => value }

    # Salvar ou atualizar a ordem com os produtos, permitindo duplicação de produtos
    connection.exec_params(
      "INSERT INTO orders (order_id, user_id, total, date, products)
         VALUES ($1, $2, $3, $4, $5)
         ON CONFLICT (order_id)
         DO UPDATE SET total = $3, date = $4, products = $5",
      [order_id, user_id, total_value, date, products.to_json]
    )
  end



  def self.save_order(connection, date, order_id, user_id, value)
    connection.exec_params(
      "INSERT INTO orders (order_id, user_id, total, date) VALUES ($1, $2, $3, $4) ON CONFLICT (order_id) DO NOTHING",
      [order_id, user_id, value, date]
    )
  end

  def self.save_user(connection, name, user_id)
    connection.exec_params(
      "INSERT INTO users (user_id, name) VALUES ($1, $2) ON CONFLICT (user_id) DO NOTHING",
      [user_id, name]
    )
  end
end
