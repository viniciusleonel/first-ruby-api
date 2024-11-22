require_relative '../services/file_service'
require_relative '../helpers/validate_file_format'

class FileController
  def self.upload_file(req, res)
    return res.status = 400, res.write({ error: 'File not provided' }.to_json) unless req.params['file']&.[](:tempfile)

    file = req.params['file'][:tempfile]
    filename = req.params['file'][:filename]

    unless filename.downcase.end_with?('.txt')
      return res.status = 400, res.write({ error: 'Invalid file type. Only .txt files are allowed.' }.to_json)
    end

    begin
      file_data = FileService.save_file(file, filename)
      if ValidateFileFormat.valid_file_format?(file_data[:file_path])
        result = FileService.process_file(file_data[:file_path])
        res.status = 201
        res['Content-Type'] = 'application/json'
        res.write(result.to_json)
        Thread.new do
          begin
            FileService.save_data_to_db(file_data[:file_path], file_data[:file_id], filename)
          rescue StandardError => e
            puts "Erro ao salvar dados no banco: #{e.message}"
          end
        end
      else
        res.status = 400
        res.write({ error: 'Invalid file format.' }.to_json)
      end
    rescue StandardError => e
      res.status = 400
      res.write({ error: "An error occurred while processing the file: #{e.message}" }.to_json)
    end
  end

  def self.get_files(req, res)
    if req.request_method == 'GET'
      page = req.params['page'] ? req.params['page'].to_i : 1
      size = req.params['size'] ? req.params['size'].to_i : 5
      res.status = 200
      res['Content-Type'] = 'application/json'
      res.write(FileService.get_files(page, size))
    else
      res.status = 404
      res.write({ error: 'Not Found' }.to_json)
    end

  end
end
