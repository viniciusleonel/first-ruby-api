require_relative '../models/order'
require_relative '../services/order.service'

class OrderController

  def self.handle_request(req, res)
    if req.request_method == 'GET'
      get_orders(req, res)
    else
      res.status = 400
      res.write({ error: 'Method Not Allowed' }.to_json)
    end
  end

  def self.handle_request_order_by_id(req, res, id)
    if req.request_method == 'GET'
      get_order_by_id(res,id)
    else
      res.status = 400
      res.write({ error: 'Method Not Allowed' }.to_json)
    end
  end

  def self.get_orders(req, res)
    page = req.params['page'] ? req.params['page'].to_i : 1
    size = req.params['size'] ? req.params['size'].to_i : 5
    start_date = req.params['start_date']
    end_date = req.params['end_date']
    res.status = 200
    res['Content-Type'] = 'application/json'
    res.write(OrderService.get_orders(page, size, start_date, end_date))
  end

  def self.get_order_by_id( res, id)
    order_data = OrderService.get_order_by_id(id)
    if order_data
      res.status = 200
      res['Content-Type'] = 'application/json'
      res.write(order_data.to_json)
    else
      res.status = 404
      res.write({ error: 'Order Not Found' }.to_json)
    end
  end
end
