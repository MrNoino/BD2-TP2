/* Criação de dois utilizadores com privilégios diferentes. Um com privilégios de consulta e outro com privilégios de 
consulta/alteração de dados */

/* Query User */
DROP OWNED BY q_user;
DROP USER IF EXISTS q_user;
CREATE USER q_user WITH PASSWORD 'Q_ESTGOH';
GRANT CONNECT ON DATABASE "IOT" TO q_user;
GRANT USAGE ON SCHEMA public TO q_user;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO q_user;


/* Query/Manipulation User*/
DROP OWNED BY q_m_user;
DROP USER IF EXISTS q_m_user;
CREATE USER q_m_user WITH PASSWORD 'Q_M_ESTGOH';
GRANT CONNECT ON DATABASE "IOT" TO q_m_user;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO q_m_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO q_m_user;