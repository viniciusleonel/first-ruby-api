Dir["./database/migrations/*.rb"].each { |file| require file }

class Migrator
  def self.migrate
    CreateUsersTable.up
    CreateOrdersTable.up
    CreateProductsTable.up
    puts "Migration ran successfully."
  end

  def self.rollback
    CreateProductsTable.down
    CreateOrdersTable.down
    CreateUsersTable.down
    puts "Migration rolled back successfully."
  end
end
