require 'pg'
require 'dotenv/load'

class Database
  def self.connect
    begin
      case ENV['PROFILE']
      when 'test'
        db_test_url = ENV['DATABASE_TEST_URL']
        PG.connect(db_test_url)
      when 'development'
        db_local_url = ENV['DATABASE_LOCAL_URL']
        PG.connect(db_local_url)
      when 'production'
        db_prod_url = ENV['DATABASE_PROD_URL']
        PG.connect(db_prod_url)
      else
        raise "Unknown PROFILE: #{ENV['PROFILE']}"
      end
    rescue PG::Error => e
      puts "Não foi possível estabelecer a conexão com o banco de dados. Verifique os links de conexão e o perfil de desenvolvimento."
      puts "Erro: #{e.message}"
      nil
    end
  end
end
