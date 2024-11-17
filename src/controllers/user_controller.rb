require_relative '../services/user_service'

class UserController
  def self.handle_request(req, res)
    if req.request_method == 'GET'
      # Pega o número da página da query string (default é 1)
      page = req.params['page'] ? req.params['page'].to_i : 1
      size = req.params['size'] ? req.params['size'].to_i : 10

      res.status = 200
      res['Content-Type'] = 'application/json'
      res.write(UserService.get_users(page, size))
    else
      res.status = 404
      res.write({ error: 'Not Found' }.to_json)
    end
  end

  def self.handle_request_by_id(req, res, id)
    if req.request_method == 'GET'
      get_user_by_id(res,id)
    else
      res.status = 404
      res.write({ error: 'Not Found' }.to_json)
    end
  end

  def self.get_user_by_id(res, id)
    user_data = UserService.get_user_by_id(id)
    if user_data
      res.status = 200
      res['Content-Type'] = 'application/json'
      res.write(user_data.to_json)
    else
      res.status = 404
      res.write({ error: 'User Not Found' }.to_json)
    end
  end
end
