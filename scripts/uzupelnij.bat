@echo off
chcp 65001 >nul
title Wypelnianie plikow MD

set "szablon=szablon.txt"

REM --- KROK 1: Sprawdzenie i utworzenie szablonu ---
if not exist "%szablon%" (
    echo [i] Plik "%szablon%" nie istnieje.
    echo [+] Tworze pusty plik "%szablon%".
    type nul > "%szablon%"
    
    echo.
    echo ---------------------------------------------------------
    echo TERAZ MASZ CZAS NA EDYCJE PLIKU "%szablon%".
    echo Wpisz w nim to, co ma trafic do wszystkich plikow .md.
    echo Jesli zostawisz go pustego, do plikow nic nie zostanie dodane.
    echo Zapisz plik txt i wroc tutaj.
    echo ---------------------------------------------------------
    pause
) else (
    echo [i] Plik "%szablon%" juz istnieje. Uzyje jego obecnej zawartosci.
)

REM --- KROK 2: Kopiowanie zawartości do plików .md ---
echo.
echo Rozpoczynam kopiowanie tresci z "%szablon%" do plikow .md...
echo ---------------------------------------------------------

for /r %%f in (*.md) do (
    REM "type" bierze tresc szablonu, ">>" dopisuje ja na koncu pliku md
    type "%szablon%" >> "%%f"
    echo [+] Uzupelniono: %%~nxf
)

echo ---------------------------------------------------------
echo Gotowe.
pause