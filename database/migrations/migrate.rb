Dir["./database/migrations/*.rb"].each { |file| require file }

class Migrator
  def self.migrate
    CreateFilesTable.up
    CreateUsersTable.up
    CreateOrdersTable.up
    puts "Migration ran successfully."
  end

  def self.rollback
    CreateOrdersTable.down
    CreateUsersTable.down
    CreateFilesTable.down
    puts "Migration rolled back successfully."
  end

  def self.clean
    CreateOrdersTable.clean
    CreateFilesTable.clean
    CreateUsersTable.clean
    puts "Migration clean successfully."
  end
end

