-- Create databases
CREATE DATABASE IF NOT EXISTS db_iemr;
CREATE DATABASE IF NOT EXISTS db_identity;
CREATE DATABASE IF NOT EXISTS db_reporting;
CREATE DATABASE IF NOT EXISTS db_1097_identity;

-- Create user with proper privileges
CREATE USER IF NOT EXISTS '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';

-- Grant privileges
GRANT ALL PRIVILEGES ON db_iemr.* TO '$MYSQL_USER'@'%';
GRANT ALL PRIVILEGES ON db_identity.* TO '$MYSQL_USER'@'%';
GRANT ALL PRIVILEGES ON db_reporting.* TO '$MYSQL_USER'@'%';
GRANT ALL PRIVILEGES ON db_1097_identity.* TO '$MYSQL_USER'@'%';

FLUSH PRIVILEGES; 