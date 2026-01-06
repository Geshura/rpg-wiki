@echo off
title MkDocs: Budowanie i Serwer
:: Ustawienie kodowania na UTF-8 (zeby polskie znaki w komunikatach sie nie krzaczyly - opcjonalne)
chcp 65001 >nul

:: Przejdz do katalogu skryptu
cd /d "%~dp0"

echo.
echo ========================================================
echo KROK 1: START SERWERA (Podglad na porcie 8001)
echo Adres: http://127.0.0.1:8001
echo ========================================================
python -m mkdocs serve -a 127.0.0.1:8001

echo.
echo Serwer zakonczyl dzialanie.
pause