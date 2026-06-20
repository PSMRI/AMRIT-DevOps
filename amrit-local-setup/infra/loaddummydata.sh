#!/bin/sh

# MySQL connection details
HOST="127.0.0.1"
PORT="3306"
USER="root"
PASSWORD="1234"

# Gitbook URL for the SQL files (AMRIT_data_dump.zip)
GITBOOK_URL="https://1865391384-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2FYfDZFIsUuulWkRHaq4c1%2Fuploads%2FYndkB40gFexKANZgvNJ1%2FAMRITMasterData.zip?alt=media&token=a8af4cf2-07c4-477e-9aa4-016c424f328a"

# download and extract the SQL files from the gitbook URL
wget -O AMRITMasterData.zip "$GITBOOK_URL"

# If wget fails, exit the script with an error message
if [ $? -ne 0 ]; then
    echo "Failed to download AMRITMasterData.zip"
    exit 1
fi

unzip -o AMRITMasterData.zip -d AMRITMasterData

# Path to the extracted SQL files. The zip contains an AMRIT_data_dump/ folder;
# locate it robustly so a change to the top-level folder name doesn't break us.
SQL_DIR=$(dirname "$(find AMRITMasterData -name db_iemr.sql -print 2>/dev/null | head -n 1)")
if [ -z "$SQL_DIR" ] || [ ! -d "$SQL_DIR" ]; then
    echo "Could not find db_iemr.sql in the extracted archive."
    exit 1
fi

# Files and their respective databases. These dumps are data-only and must be
# restored AFTER the AMRIT-DB Flyway schema migration. They use column-qualified
# INSERT IGNORE statements, so they tolerate rows already seeded by Flyway.
# db_reporting.sql carries no data (schema + procedures come from Flyway).
FILES="db_iemr.sql db_identity.sql db_1097_identity.sql db_reporting.sql"
DATABASES="db_iemr db_identity db_1097_identity db_reporting"

# Convert space-separated strings into arrays
FILES_ARRAY=$(echo $FILES)
DATABASES_ARRAY=$(echo $DATABASES)

# Iterate over the files and execute them
i=0
for FILE in $FILES_ARRAY; do
    DATABASE=$(echo $DATABASES_ARRAY | cut -d ' ' -f $(($i+1)))  # get corresponding database
    i=$(($i+1))  # Increment index for the next database

    if [ ! -f "$SQL_DIR/$FILE" ]; then
        echo "Skipping $FILE (not found in archive)."
        continue
    fi

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
done

# Clean up the temporary files
rm AMRITMasterData.zip
rm -rf AMRITMasterData
echo "Cleaned up AMRITMasterData folder."
