require_relative '../controllers/user_controller'
require_relative '../controllers/order_controller'
require_relative '../controllers/api_controller'
require_relative '../controllers/file_controller'

class Router
  def self.call(req, res)
    id = req.path.split('/').last.to_i if req.path.split('/').last =~ /\d/

    case req.path
    when '/'
      ApiController.handle_request(req, res)
    when '/orders'
      OrderController.handle_request(req, res)
    when "/orders/#{id}"
      OrderController.handle_request_order_by_id(req, res, id)
    when "/upload"
      FileController.upload_file(req, res)
    when "/files"
      FileController.get_files(req, res)
    else
      res.status = 404
      res.write({ error: 'Endpoint Not Found' }.to_json)
    end
  end
end 