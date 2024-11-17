require_relative '../models/user'
require_relative '../../database/config/database'

class UserService
  def self.get_users(page, size)
    connection = Database.connect

    # Calcula o offset com base na página
    offset = (page - 1) * size
    limit = size

    # Consulta os usuários com limite e offset para paginação
    users = connection.exec_params("SELECT * FROM users LIMIT $1 OFFSET $2", [limit, offset])
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
end
