-- Create databases if they don't exist
CREATE DATABASE IF NOT EXISTS db_iemr;
CREATE DATABASE IF NOT EXISTS db_identity;
CREATE DATABASE IF NOT EXISTS db_reporting;
CREATE DATABASE IF NOT EXISTS db_1097_identity;

-- Create database user with privileges
CREATE USER IF NOT EXISTS 'dbuser'@'%' IDENTIFIED BY '1234';

-- Grant privileges to the user for all databases
GRANT ALL PRIVILEGES ON db_iemr.* TO 'dbuser'@'%';
GRANT ALL PRIVILEGES ON db_identity.* TO 'dbuser'@'%';
GRANT ALL PRIVILEGES ON db_reporting.* TO 'dbuser'@'%';
GRANT ALL PRIVILEGES ON db_1097_identity.* TO 'dbuser'@'%';

-- Apply changes
FLUSH PRIVILEGES; 