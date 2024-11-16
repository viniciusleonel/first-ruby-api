require_relative '../../database/config/database'

class User
  attr_accessor :id, :name, :email

  def initialize(id = nil, name, email)
    @id = id
    @name = name
    @email = email
  end

  def self.create(name, email)
    connection = Database.connect
    result = connection.exec_params("INSERT INTO users (name, email) VALUES ($1, $2) RETURNING id", [name, email])
    User.new(result[0]['id'], name, email)
  end

  def self.all
    connection = Database.connect
    result = connection.exec("SELECT * FROM users;")
    result.map { |row| User.new(row['id'], row['name'], row['email']) }
  end
end