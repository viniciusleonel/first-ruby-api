DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_database WHERE datname = 'luizalabs') THEN
        CREATE DATABASE luizalabs;
    END IF;
END
$$;
