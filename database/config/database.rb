require 'pg'

class Database
  def self.connect
    PG.connect(
      dbname: 'luizalabs',
      user: 'postgres',
      password: '123456',
      host: 'db',
      port: 5432
    )
  end
end