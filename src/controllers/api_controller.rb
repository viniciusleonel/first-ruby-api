require_relative '../../database/config/database'
require_relative '../services/api_service'

class ApiController

  def self.handle_request(req, res)
    if req.request_method == 'GET'
      get_data(req, res)
    elsif req.request_method == 'POST'
      save_data(req, res)
    else
      res.status = 404
      res.write({ error: 'Not Found' }.to_json)
    end
  end

  def self.get_data(req, res)
    # Pega o número da página da query string (default é 1)
    page = req.params['page'] ? req.params['page'].to_i : 1
    size = req.params['size'] ? req.params['size'].to_i : 5

    res.status = 200
    res['Content-Type'] = 'application/json'
    res.write(ApiService.get_data(page, size))
  end

  def self.save_data(req, res)

    connection = Database.connect
    connection.exec("BEGIN")

    begin
      data = JSON.parse(req.body.read)

      ApiService.save_data(data, connection)

      res.status = 201
      res['Content-Type'] = 'application/json'
      res.write({ message: 'Data saved successfully' }.to_json)

      # Comita a transação (confirma as alterações)
      connection.exec("COMMIT")
    rescue JSON::ParserError
      # Caso a requisição não tenha um JSON válido
      res.status = 400
      connection.exec("ROLLBACK")
      res['Content-Type'] = 'application/json'
      res.write({ error: 'Invalid JSON format' }.to_json)

    rescue => e
      # Caso ocorra algum outro erro
      res.status = 500
      connection.exec("ROLLBACK")
      res['Content-Type'] = 'application/json'
      res.write({ error: 'Internal Server Error', message: e.message }.to_json)
    end
  ensure
    connection.close
  end
end