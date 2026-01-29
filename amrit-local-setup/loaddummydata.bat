@echo off

:: MySQL connection details
set HOST=127.0.0.1
set PORT=3306
set USER=root
set PASSWORD=1234

:: Download the file using PowerShell's Invoke-WebRequest (equivalent to wget)
echo Downloading AmritMasterData.zip...
powershell -Command "Invoke-WebRequest -Uri 'https://1865391384-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2FYfDZFIsUuulWkRHaq4c1%2Fuploads%2F1WdSAf0fQBeJOea70EXE%2FAmritMasterData.zip?alt=media&token=18e0b6d6-487c-4c0c-967a-02cdd94d61ad' -OutFile 'AmritMasterData.zip'"

:: Extract the file using PowerShell's Expand-Archive (equivalent to unzip)
echo Extracting AmritMasterData.zip...
powershell -Command "Expand-Archive -Path 'AmritMasterData.zip' -DestinationPath 'AmritMasterDataFiles'"

:: Path to the extracted SQL files
set SQL_DIR="AmritMasterDataFiles/AmritMasterData"

:: Associating files with databases
set DATABASES="AmritMasterData.sql=db_iemr" "m_beneficiaryregidmapping_dump_1097.sql=db_1097_identity" "m_beneficiaryregidmapping_dump.sql=db_identity"

:: Iterate over the SQL files and execute them
for %%F in (%DATABASES%) do (
    for /f "tokens=1,2 delims==" %%A in (%%F) do (
        set "FILE=%%A"
        set "DATABASE=%%B"
        echo Running %%A on %%B...
        
        mysql -h %HOST% -P %PORT% -u %USER% -p%PASSWORD% %%B < "%SQL_DIR%\%%A"
        
        if %ERRORLEVEL% equ 0 (
            echo Successfully executed %%A on %%B.
        ) else (
            echo Error executing %%A on %%B.
        )
    )
)

pause

# Clean up the extracted files
del AmritMasterData.zip
rmdir /s /q AmritMasterDataFiles
echo Cleaned up AmritMasterDataFiles folder.
