#!/bin/sh

# MySQL connection details
HOST="127.0.0.1"
PORT="3306"
USER="root"
PASSWORD="1234"

# Gitbook URL for the SQL files
GITBOOK_URL="https://1865391384-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2FYfDZFIsUuulWkRHaq4c1%2Fuploads%2F1WdSAf0fQBeJOea70EXE%2FAmritMasterData.zip?alt=media&token=18e0b6d6-487c-4c0c-967a-02cdd94d61ad"

# download and extract the SQL files from the gitbook URL
wget -O AmritMasterData.zip "$GITBOOK_URL"

# If wget fails, exit the script with an error message
if [ $? -ne 0 ]; then
    echo "Failed to download AmritMasterData.zip"
    exit 1
fi

unzip AmritMasterData.zip -d AmritMasterData

# Path to the extracted SQL files
SQL_DIR=AmritMasterData/AmritMasterData

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
    
    # Execute SQL and capture output, filtering out duplicate key errors
    OUTPUT=$(mysql -h "$HOST" -P "$PORT" -u "$USER" -p"$PASSWORD" "$DATABASE" < "$SQL_DIR/$FILE" 2>&1)
    EXIT_CODE=$?
    
    # Check if error is only due to duplicate entries (error code 1062)
    if [ $EXIT_CODE -eq 0 ]; then
        echo "Successfully executed $FILE on $DATABASE."
    elif echo "$OUTPUT" | grep -q "ERROR 1062"; then
        echo "Completed $FILE on $DATABASE (duplicate entries skipped)."
    else
        echo "Error executing $FILE on $DATABASE: $OUTPUT"
    fi
    i=$(($i+1))  # Increment index for the next database
done

# Clean up the temporary files
rm AmritMasterData.zip
rm -rf AmritMasterData
echo "Cleaned up AmritMasterData folder."
