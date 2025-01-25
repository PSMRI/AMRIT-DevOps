#!/bin/sh

# MySQL connection details
HOST="127.0.0.1"
PORT="3306"
USER="root"
PASSWORD="1234"
# Path to the extracted SQL files
SQL_DIR="/home/asp-irin/Desktop/amrit/main-repo/AmritMasterData"

# Files and their respective databases
FILES="AmritMasterData.sql m_beneficiaryregidmapping_dump_1097.sql m_beneficiaryregidmapping_dump.sql"
DATABASES="db_iemr db_1097_identity db_identity"

# Convert space-separated strings into arrays
FILES_ARRAY=$(echo $FILES)
DATABASES_ARRAY=$(echo $DATABASES)

# Iterate over the files and execute them
i=0
for FILE in $FILES_ARRAY; do
    DATABASE=$(echo $DATABASES_ARRAY | cut -d ' ' -f $(($i+1)))  # get corresponding database
    echo "Running $FILE on $DATABASE..."
    
    mysql -h "$HOST" -P "$PORT" -u "$USER" -p"$PASSWORD" "$DATABASE" < "$SQL_DIR/$FILE"
    
    if [ $? -eq 0 ]; then
        echo "Successfully executed $FILE on $DATABASE."
    else
        echo "Error executing $FILE on $DATABASE."
    fi
    i=$(($i+1))  # Increment index for the next database
done
