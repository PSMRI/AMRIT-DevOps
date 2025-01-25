#!/bin/sh

# MySQL connection details
HOST="127.0.0.1"
PORT="3306"
USER="root"
PASSWORD="1234"

# Path to the extracted SQL files
SQL_DIR=<PATH to the extracted files directory>

# Files and their respective databases
FILES=("AmritMasterData.sql" "m_beneficiaryregidmapping_dump_1097.sql" "m_beneficiaryregidmapping_dump.sql")
DATABASES=("db_iemr" "db_1097_identity" "db_identity")

# Iterate over the files and execute them
for i in $(seq 0 $((${#FILES[@]} - 1))); do
    FILE="${FILES[$i]}"
    DATABASE="${DATABASES[$i]}"
    echo "Running $FILE on $DATABASE..."
    
    mysql -h "$HOST" -P "$PORT" -u "$USER" -p"$PASSWORD" "$DATABASE" < "$SQL_DIR/$FILE"

    if [ $? -eq 0 ]; then
        echo "Successfully executed $FILE on $DATABASE."
    else
        echo "Error executing $FILE on $DATABASE."
    fi
done

