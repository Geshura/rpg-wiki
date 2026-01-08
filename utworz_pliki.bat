@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: 1. Tworzenie katalogu, jesli nie istnieje
if not exist "sciezki_mistrzowskie" (
    mkdir "sciezki_mistrzowskie"
    echo [OK] Utworzono katalog: sciezki_mistrzowskie
)

:: 2. Lista plików do utworzenia
call :utworz duch_walki.md
call :utworz kriomanta.md
call :utworz skald.md
call :utworz wieszcz.md
call :utworz kroczacy_przez_pyl.md
call :utworz pogromca_nieumarlych.md
call :utworz spaczeniec.md
call :utworz diabolista.md
call :utworz lowca_czarownic.md
call :utworz lowca_trolli.md
call :utworz morrigan.md
call :utworz mroczny_kocur.md
call :utworz muza.md
call :utworz nocny_lowca.md
call :utworz rusznimag.md
call :utworz straznik_plomienia.md
call :utworz uwodziciel.md
call :utworz wiekuisty_obronca.md
call :utworz zwiastun.md
call :utworz alchemik.md
call :utworz czarnogwardzista.md
call :utworz demonolog.md
call :utworz entropista.md
call :utworz krwiozerca.md
call :utworz lamacz_umyslow.md
call :utworz medium.md
call :utworz mistrz_sztuk_walki.md
call :utworz obserwator.md
call :utworz psychokinetyk.md
call :utworz saper.md
call :utworz zadzior.md

echo.
echo --- Zakonczono tworzenie plikow ---
pause
goto :eof

:: --- FUNKCJA TWORZACA PLIK ---
:utworz
set "filename=%1"
set "filepath=sciezki_mistrzowskie\%filename%"

if not exist "%filepath%" (
    :: Tworzy plik z nagłówkiem H1 odpowiadającym nazwie pliku (bez .md)
    echo # %filename:.md=% > "%filepath%"
    echo [OK] Utworzono: %filepath%
) else (
    echo [!] Plik juz istnieje: %filepath%
)
goto :eof