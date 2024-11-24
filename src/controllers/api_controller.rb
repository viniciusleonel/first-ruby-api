require_relative '../../database/config/database'
require_relative '../services/api_service'

class ApiController

  def self.handle_request(req, res)
    if req.request_method == 'GET'
      get_data(req, res)
    else
      res.status = 400
      res.write({ error: 'Method Not Allowed' }.to_json)
    end
  end

  def self.get_data(req, res)
    page = req.params['page'] ? req.params['page'].to_i : 1
    size = req.params['size'] ? req.params['size'].to_i : 5
    res.status = 200
    res['Content-Type'] = 'application/json'
    res.write(ApiService.get_data(page, size))
  end

end