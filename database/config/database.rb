require 'pg'
require 'dotenv/load'

class Database
  def self.connect
    db_prod_url = ENV['DATABASE_PROD_URL']
    db_local_url = ENV['DATABASE_LOCAL_URL']

    if db_prod_url.nil? || db_prod_url.empty?
      PG.connect(db_local_url)
    else
      PG.connect(db_prod_url)
    end
  end
end
