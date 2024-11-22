class File
  attr_accessor :file_id, :name, :date

  def initialize(file_id:, name:, date:)
    @file_id = file_id
    @name = name
    @date = date
  end
end