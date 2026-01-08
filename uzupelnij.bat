@echo off
chcp 65001 >nul
title Masowe uzupelnianie plikow MD

REM --- KONFIGURACJA ---
set "plik_zrodlowy=szablon_wsadu.txt"

REM 1. TWORZENIE PLIKU Z TREŚCIĄ (SZABLONU)
REM Edytuj poniższe linie, aby zmienić to, co trafi do plików .md
REM Znak "echo." oznacza pustą linię.

echo Tworzenie pliku zrodlowego z trescia...

(
echo # Tytuł
echo.
echo ## Opis
echo Tutaj wpisz opis zaklecia lub tradycji.
echo.
echo ## Statystyki
echo * Koszt:
echo * Czas rzucania:
echo * Zasięg:
) > "%plik_zrodlowy%"

echo Plik "%plik_zrodlowy%" zostal utworzony.
echo.

REM 2. ROZPROWADZANIE TREŚCI PO PLIKACH .MD
echo Rozpoczynam wpisywanie tresci do plikow .md...
echo --------------------------------------------

REM Pętla for /r przeszukuje rekurencyjnie wszystkie podkatalogi
for /r %%f in (*.md) do (
    REM "type" odczytuje szablon, ">>" dopisuje go na koniec pliku md
    REM Jeśli chcesz NADPISAĆ pliki (skasować starą treść), zmień ">>" na ">"
    type "%plik_zrodlowy%" >> "%%f"
    echo [+] Zaktualizowano: %%~nxf
)

echo --------------------------------------------
REM Opcjonalnie: usunięcie pliku źródłowego po zakończeniu (usuń "REM" z początku linii poniżej, aby aktywować)
REM del "%plik_zrodlowy%"

echo Gotowe! Wszystkie pliki .md otrzymaly nowa tresc.
pause