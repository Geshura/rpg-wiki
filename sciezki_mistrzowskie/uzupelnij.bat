@echo off
chcp 65001 >nul
title Masowe NADPISYWANIE plikow MD

set "szablon=szablon.txt"

REM --- KROK 1: Sprawdzenie szablonu ---
if not exist "%szablon%" (
    echo [i] Plik "%szablon%" nie istnieje.
    echo [+] Tworze pusty plik "%szablon%".
    type nul > "%szablon%"
    
    echo.
    echo ---------------------------------------------------------
    echo WAŻNE: Edytuj teraz plik "%szablon%".
    echo Wpisz w nim treść, która ma zastąpić zawartość wszystkich plików .md.
    echo Zapisz plik i wroć tutaj, aby kontynuować.
    echo ---------------------------------------------------------
    pause
) else (
    echo [i] Znaleziono plik "%szablon%".
)

REM --- KROK 2: Nadpisywanie plików ---
echo.
echo !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
echo UWAGA: Wszystkie pliki .md w tym folderze i podfolderach 
echo zostana CALKOWICIE NADPISANE trescia z "%szablon%".
echo Stara zawartosc tych plikow zostanie bezpowrotnie utracona.
echo !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
echo.
echo Nacisnij dowolny klawisz, aby potwierdzic i rozpoczac...
pause >nul

echo Rozpoczynam nadpisywanie...
echo ---------------------------------------------------------

for /r %%f in (*.md) do (
    REM Operator ">" czysci plik docelowy i wstawia nowa tresc
    type "%szablon%" > "%%f"
    echo [OK] Nadpisano: %%~nxf
)

echo ---------------------------------------------------------
echo Gotowe.
pause