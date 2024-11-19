require_relative '../services/file_service'

class FileController
  def self.handle_request(req, res)
    if req.request_method == 'POST'
      if req.params['file'] && req.params['file'][:tempfile]
        # page = req.params['page'] ? req.params['page'].to_i : 1
        # size = req.params['size'] ? req.params['size'].to_i : 5
        file = req.params['file'][:tempfile]
        filename = req.params['file'][:filename]

        file_path = FileService.save_file(file, filename)
        result = FileService.process_file(file_path)

        res.status = 201
        res['Content-Type'] = 'application/json'
        res.write(result.to_json)

        Thread.new do
          FileService.save_data_to_db(file_path, filename)
        end

      else
        res.status = 400
        res.write({ error: 'File not provided' }.to_json)
      end
    else
      res.status = 404
      res.write({ error: 'Not Found' }.to_json)
    end
  end
end
