@echo off

:: MySQL connection details
set HOST=127.0.0.1
set PORT=3307
set USER=root
set PASSWORD=1234

:: Path to the extracted SQL files
set SQL_DIR=<PATH to the  extracted files directory>

:: Associating files with databases
set DATABASES=db_iemr_masterdata.sql=db_iemr
set DATABASES=%DATABASES% m_beneficiaryregidmapping_dump_1097.sql=db_1097_identity
set DATABASES=%DATABASES% m_beneficiaryregidmapping_dump.sql=db_identity

:: Iterate over the SQL files and execute them
for %%F in (%DATABASES%) do (
    set "FILE=%%~F"
    for /f "tokens=1,2 delims==" %%A in ("%%F") do (
        set "DATABASE=%%B"
        echo Running %%A on %DATABASE%...
        
        mysql -h %HOST% -P %PORT% -u %USER% -p%PASSWORD% %DATABASE% < "%SQL_DIR%\%%A"
        
        if %ERRORLEVEL% equ 0 (
            echo Successfully executed %%A on %DATABASE%.
        ) else (
            echo Error executing %%A on %DATABASE%.
        )
    )
)

pause
