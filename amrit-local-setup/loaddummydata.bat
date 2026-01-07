@echo off
setlocal enabledelayedexpansion

:: MySQL connection details
set HOST=127.0.0.1
set PORT=3306
set USER=root
set PASSWORD=1234

:: Path to the extracted SQL files, DO NOT put in quotes
set SQL_DIR=<PATH to the extracted files directory>

:: Associating files with databases
set DATABASES="AmritMasterData.sql=db_iemr" "m_beneficiaryregidmapping_dump_1097.sql=db_1097_identity" "m_beneficiaryregidmapping_dump.sql=db_identity"

:: Iterate over the SQL files and execute them
:: added strings to variables to avoid issues with spaces in paths
for %%F in (%DATABASES%) do (
    for /f "tokens=1,2 delims==" %%A in ("%%~F") do (
        set "FILE=%%A"
        set "DATABASE=%%B"
        echo Running !FILE! on !DATABASE!...
        
        mysql -h %HOST% -P %PORT% -u %USER% -p%PASSWORD% !DATABASE! < "%SQL_DIR%\!FILE!"
        
        if !ERRORLEVEL! equ 0 (
            echo Successfully executed !FILE! on !DATABASE!.
        ) else (
            echo Error executing !FILE! on !DATABASE!.
        )
    )
)

pause
endlocal
