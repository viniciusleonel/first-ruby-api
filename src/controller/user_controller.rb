require_relative '../models/user'

class UserController

  def self.create(request)
    data = JSON.parse(request.body.read)
    user = User.create(data['name'], data['email'])
    {status: "sucess", user: {id: user.id, name: user.name, email: user.email}}.to_json

  end

  def self.index
    users = User.all
    users_data = users.map { |user| {id: user.id, name: user.name, email: user.email}}
    {users: users_data}.to_json
  end
end
