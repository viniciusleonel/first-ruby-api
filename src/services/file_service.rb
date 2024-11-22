require 'async'

class FileService
  def self.save_file(file, filename)
    uploads_folder = "uploads"

    Dir.mkdir(uploads_folder) unless Dir.exist?(uploads_folder)

    filename_without_extension = filename.gsub('.txt', '')
    if file_exists_in_db?(filename_without_extension)
      raise "Erro: O arquivo '#{filename}' já existe no banco de dados."
    end
    file_id = save_file_name_to_db(filename_without_extension)

    file_path = "#{uploads_folder}/#{filename}"
    File.open(file_path, 'wb') do |f|
      f.write(file.read)
    end

    puts "Arquivo '#{filename}' salvo com sucesso em #{uploads_folder}/"

    { file_path: file_path, file_id: file_id }
  end

  def self.get_files(page, size)
    connection = Database.connect
    offset = (page - 1) * size
    limit = size
    files = connection.exec_params(
      "SELECT * FROM files LIMIT $1 OFFSET $2",
      [limit, offset]
    )
    total_files = connection.exec_params(
      "SELECT COUNT(*) FROM files"
    ).first['count'].to_i
    total_pages = (total_files / size.to_f).ceil
    connection.close
    files_list = files.map do |file|
      {
        file_id: file['file_id'],
        name: file['name'],
        date: file['date']
      }
    end

    {
      files: files_list,
      page: page,
      size: size,
      total_files: total_files,
      total_pages: total_pages
    }.to_json
  end


  def self.save_file_name_to_db(filename_without_extension)
    connection = Database.connect
    begin
      result = connection.exec_params(
        "INSERT INTO files (name, date) VALUES ($1, $2) RETURNING file_id",
        [filename_without_extension, Time.now]
      )
      result[0]['file_id']
    ensure
      connection.close
    end
  end


  def self.file_exists_in_db?(filename_without_extension)
    connection = Database.connect
    result = connection.exec_params(
      "SELECT COUNT(*) FROM files WHERE name = $1",
      [filename_without_extension]
    )
    result.first['count'].to_i > 0
    connection.close
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


  def self.save_data_to_db(file_path,file_id, filename)
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
          save_order_with_products(connection, order_id, user_id, value, date, product_id, value, file_id)

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

  def self.save_order_with_products(connection, order_id, user_id, total_value, date, product_id, value, file_id)
    puts "Recuperando o id do arquivo file: #{file_id}"
    existing_order = connection.exec_params(
      "SELECT products FROM orders WHERE order_id = $1", [order_id]
    ).first
    products = existing_order ? JSON.parse(existing_order['products']) : []
    products << { "product_id" => product_id, "value" => value }
    save_order(connection, date, file_id, order_id, products, total_value, user_id)
  end

  def self.save_order(connection, date, file_id, order_id, products, total_value, user_id)
    connection.exec_params(
      "INSERT INTO orders (order_id, user_id, total, date, products, file_id)
         VALUES ($1, $2, $3, $4, $5, $6)
         ON CONFLICT (order_id)
         DO UPDATE SET total = $3, date = $4, products = $5",
      [order_id, user_id, total_value, date, products.to_json, file_id]
    )
  end

  def self.save_user(connection, name, user_id)
    connection.exec_params(
      "INSERT INTO users (user_id, name) VALUES ($1, $2) ON CONFLICT (user_id) DO NOTHING",
      [user_id, name]
    )
  end
end
