require_relative '../services/file_service'
require_relative '../helpers/validate_file_format'

class FileController
  def self.handle_request(req, res)
    if req.request_method == 'POST'
      if req.params['file'] && req.params['file'][:tempfile]
        # page = req.params['page'] ? req.params['page'].to_i : 1
        # size = req.params['size'] ? req.params['size'].to_i : 5
        file = req.params['file'][:tempfile]
        filename = req.params['file'][:filename]

        if filename.downcase.end_with?('.txt')
          file_path = FileService.save_file(file, filename)
          begin
            if ValidateFileFormat.valid_file_format?(file_path)
              result = FileService.process_file(file_path)
              puts "Nome do arquivo #{filename}"

              res.status = 201
              res['Content-Type'] = 'application/json'
              res.write(result.to_json)

              Thread.new do
                FileService.save_data_to_db(file_path, filename)
              end
            else
              res.status = 400
              res['Content-Type'] = 'application/json'
              res.write({ error: 'Invalid file format. The file must match the expected format.' }.to_json)
            end
          rescue StandardError => e
            res.status = 500
            res['Content-Type'] = 'application/json'
            res.write({ error: "An error occurred while processing the file: #{e.message}" }.to_json)
          end
        else
          res.status = 400
          res.write({ error: 'Invalid file type. Only .txt files are allowed.' }.to_json)
        end

      else
        res.status = 400
        res.write({ error: 'File not provided' }.to_json)
      end
    end
  end
end
