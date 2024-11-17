require_relative '../models/order'

class OrderController
  def self.index
    orders = Order.all
    orders.to_json
  end

  def self.create(req)
    data = JSON.parse(req.body.read)
    order = Order.create(data['user_id'], data['total'], data['date'])
    order.to_json
  end
end
