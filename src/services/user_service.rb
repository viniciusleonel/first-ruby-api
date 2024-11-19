require_relative '../models/user'
require_relative '../../database/config/database'

class UserService
  def self.get_users(page, size)
    connection = Database.connect

    offset = (page - 1) * size
    limit = size

    users = connection.exec_params("SELECT * FROM users ORDER by name LIMIT $1 OFFSET $2", [limit, offset])
    total_users = connection.exec("SELECT COUNT(*) FROM users").first['count'].to_i
    total_pages = (total_users / size.to_f).ceil

    connection.close

    {
      users: users,
      total_users: total_users,
      total_pages: total_pages
    }
  end

  def self.create_user(user_id, user_name, connection)
    connection.exec_params("INSERT INTO users (user_id, name) VALUES ($1, $2)", [user_id, user_name])
  end

  def self.get_user_by_id(id)
    connection = Database.connect
    user = connection.exec_params("SELECT * FROM users WHERE user_id = $1", [id]).first
    connection.close
    user ? { user_id: user['user_id'], name: user['name'] } : nil
  end
end
