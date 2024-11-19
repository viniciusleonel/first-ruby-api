require_relative '../models/user'
require_relative '../../database/config/database'

class OrderService
  def self.get_orders_by_user_id(user_id)
    connection = Database.connect
    orders = connection.exec_params("SELECT * FROM orders WHERE user_id = $1 ", [user_id])
    connection.close
    orders
  end

  def self.get_order_by_id(id)
    connection = Database.connect
    order = connection.exec_params("SELECT * FROM orders WHERE order_id = $1 ", [id]).first

    products = order ? JSON.parse(order['products']) : []

    connection.close
    order ? {
      order_id: order['order_id'],
      user_id: order['user_id'],
      total: order['total'],
      date: order['date'],
      products: products
    } : nil
  end

  def self.get_orders(page, size, start_date, end_date)
    connection = Database.connect

    offset = (page - 1) * size
    limit = size

    if start_date && end_date
      orders = connection.exec_params(
        "SELECT * FROM orders WHERE date >= $1 AND date <= $2 ORDER BY date LIMIT $3 OFFSET $4",
        [start_date, end_date, limit, offset]
      )
      total_orders = connection.exec_params(
        "SELECT COUNT(*) FROM orders WHERE date >= $1 AND date <= $2",
        [start_date, end_date]
      ).first['count'].to_i
    else
      orders = connection.exec_params(
        "SELECT * FROM orders ORDER BY date LIMIT $1 OFFSET $2",
        [limit, offset]
      )
      total_orders = connection.exec(
        "SELECT COUNT(*) FROM orders"
      ).first['count'].to_i
    end

    total_pages = (total_orders / size.to_f).ceil

    orders_data = orders.map do |order|
      products = JSON.parse(order['products'])
      {
        order_id: order['order_id'],
        user_id: order['user_id'],
        total: order['total'],
        date: order['date'],
        products: products
      }
    end

    connection.close

    {
      orders: orders_data,
      page: page,
      size: size,
      total_orders: total_orders,
      total_pages: total_pages,
    }.to_json
  end

  def self.create_order(order_id, user_id, value, date, connection)
    connection.exec_params("INSERT INTO orders (order_id, user_id, total, date) VALUES ($1, $2, $3, $4)", [order_id, user_id, value, date])
  end
end
