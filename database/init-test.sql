DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_database WHERE datname = 'luizalabs_test') THEN
        CREATE DATABASE luizalabs_test;
    END IF;
END
$$;
