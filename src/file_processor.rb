require 'date'

class FileProcessor
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
end