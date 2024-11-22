require_relative '../services/file_service'
require_relative '../helpers/validate_file_format'

class FileController
  def self.handle_request(req, res)
    return res.status = 400, res.write({ error: 'File not provided' }.to_json) unless req.params['file']&.[](:tempfile)

    file = req.params['file'][:tempfile]
    filename = req.params['file'][:filename]

    unless filename.downcase.end_with?('.txt')
      return res.status = 400, res.write({ error: 'Invalid file type. Only .txt files are allowed.' }.to_json)
    end

    file_path = FileService.save_file(file, filename)
    begin
      if ValidateFileFormat.valid_file_format?(file_path)
        result = FileService.process_file(file_path)
        res.status = 201
        res['Content-Type'] = 'application/json'
        res.write(result.to_json)
        Thread.new { FileService.save_data_to_db(file_path, filename) }
      else
        res.status = 400
        res.write({ error: 'Invalid file format.' }.to_json)
      end
    rescue StandardError => e
      res.status = 400
      res.write({ error: "An error occurred while processing the file: #{e.message}" }.to_json)
    end
  end
end
