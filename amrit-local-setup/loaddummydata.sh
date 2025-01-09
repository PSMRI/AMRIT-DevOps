#!/bin/bash

# MySQL connection details
HOST="127.0.0.1"
PORT="3306"
USER="root"
PASSWORD="1234"

# Path to the extracted SQL files
SQL_DIR=<PATH to the extracted files directory>

# Associating files with databases
declare -A DATABASES
DATABASES["AmritMasterData.sql"]="db_iemr"
DATABASES["m_beneficiaryregidmapping_dump_1097.sql"]="db_1097_identity"
DATABASES["m_beneficiaryregidmapping_dump.sql"]="db_identity"

# Iterate over the SQL files and execute them
for FILE in "${!DATABASES[@]}"; do
    DATABASE=${DATABASES[$FILE]}
    echo "Running $FILE on $DATABASE..."
    
     mysql -h 127.0.0.1 -P 3306 -u root -p"$PASSWORD" "$DATABASE" < "$SQL_DIR/$FILE"

    if [ $? -eq 0 ]; then
        echo "Successfully executed $FILE on $DATABASE."
    else
        echo "Error executing $FILE on $DATABASE."
    fi
done
