Dir["./database/migrations/*.rb"].each { |file| require file }

class Migrator
  def self.migrate
    CreateUsersTable.up
    puts "Migration ran successfully."
  end

  def self.rollback
    CreateUsersTable.down
    puts "Migration rolled back successfully."
  end
end
