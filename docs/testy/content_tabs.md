---
title: Ultimate MkDocs Demo v2
description: Maksymalnie rozbudowany przykład funkcji MkDocs Material.
icon: material/shimmer
status: new
---

# Demonstracja Funkcji MkDocs Material (Wersja MAX)

[TOC]

---

## 1. Interaktywne Przyciski i Ikony

Możesz zamieniać zwykłe linki w przyciski, używając atrybutów (wymaga `attr_list`).

[Subskrybuj teraz](#){ .md-button }
[Główny Przycisk](#){ .md-button .md-button--primary }
[Ikona Serca ♥](#){ .md-button .md-button--primary }

Możesz też używać dowolnej ikony z zestawu Material Design w tekście:
To jest ikona bazy danych: :material-database: a to ikona dockera: :simple-docker:.

---

## 2. CriticMarkup (Tryb Recenzji)

Świetne do pokazywania zmian w dokumentacji lub kodzie.

- {--To zostało usunięte.--}
- {++To zostało dodane.++}
- {~~To zostało zmienione.~~>To jest nowa wersja.}
- {==Ten fragment jest po prostu zaznaczony (highlight).==}
- {>>To jest komentarz recenzenta.<<}

---

## 3. Admonitions (Alerty) - Pełna Paleta

!!! note "Notatka"
    Standardowa notatka.

!!! abstract "Abstrakt / Podsumowanie"
    Krótkie podsumowanie rozdziału.

!!! info "Informacja"
    Dodatkowe informacje, mniej ważne niż notatka.

!!! tip "Wskazówka"
    Porada dla użytkownika.

!!! success "Sukces"
    Operacja zakończona powodzeniem.

!!! question "Pytanie"
    Często zadawane pytanie.

!!! warning "Ostrzeżenie"
    Uważaj na ten fragment.

!!! failure "Błąd"
    Coś poszło nie tak.

!!! danger "Niebezpieczeństwo"
    Krytyczne ostrzeżenie.

!!! bug "Zgłoszenie błędu"
    Tutaj opisujemy znany bug.

!!! example "Przykład"
    Przykład użycia funkcji.

!!! quote "Cytat"
    Cytat z dokumentacji zewnętrznej.

---

## 4. Karty (Content Tabs)

Grupowanie treści (np. dla różnych systemów operacyjnych).

=== "Linux / macOS"
    ```bash
    # Instalacja pakietów
    python3 -m pip install mkdocs-material
    ```

=== "Windows"
    ```powershell
    # Instalacja pakietów
    pip install mkdocs-material
    ```

=== "Docker"
    ```yaml
    image: squidfunk/mkdocs-material
    ```

---

## 5. Zaawansowane Bloki Kodu

Kod z tytułem pliku, numeracją linii, podświetleniem i "dymkami" objaśniającymi.

```python title="src/service.py" linenums="1" hl_lines="3-4"
from fastapi import FastAPI

app = FastAPI() # (1)!
# Ta linia i następna są podświetlone w tle
@app.get("/")
def read_root():
    return {"Hello": "World"}
	
# Symulator Rzutu Kością (Wersja przeglądarkowa)

Ten dokument zawiera kompletny kod strony internetowej (HTML/CSS/JS), która symuluje rzut kością. Program wyświetla dużą ikonę kości, animuje rzut i losuje wynik.

---

## 1. Kod Strony

Poniżej znajduje się kompletny kod. Skopiuj go w całości.

<style>
    /* Kontener główny */
    .dice-widget-container {
        font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        background-color: #1e1e1e;
        color: #ffffff;
        padding: 2rem;
        border-radius: 15px;
        box-shadow: 0 10px 30px rgba(0,0,0,0.5);
        text-align: center;
        width: 100%;
        max-width: 450px; /* Nieco szerszy */
        border: 1px solid #333;
        margin: 0 auto;
        box-sizing: border-box;
    }

    .dice-widget-container h2 {
        margin-top: 0;
        color: #ffca28;
        font-size: 1.5rem;
        text-transform: uppercase;
        letter-spacing: 2px;
        margin-bottom: 20px;
    }

    /* Wyświetlacz wyniku */
    .dice-result-box {
        background-color: #2c2c2c;
        border: 2px solid #6a1b9a;
        border-radius: 10px;
        padding: 15px;
        margin-bottom: 20px;
        min-height: 90px;
        display: flex;
        flex-direction: column;
        justify-content: center;
        align-items: center;
    }

    .dice-result-number {
        font-size: 3.5rem;
        font-weight: bold;
        color: #fff;
        margin: 0;
        line-height: 1;
    }

    .dice-result-label {
        font-size: 0.95rem;
        color: #aaa;
        margin-top: 10px;
        word-wrap: break-word; /* Złamanie długich linii przy wielu kościach */
        max-width: 100%;
    }

    /* Sekcja wyboru liczby kości */
    .dice-count-row {
        display: flex;
        justify-content: center;
        align-items: center;
        margin-bottom: 15px;
        background: #333;
        padding: 10px;
        border-radius: 8px;
    }

    .dice-count-label {
        margin-right: 10px;
        font-weight: bold;
        color: #ffca28;
    }

    /* Siatka przycisków */
    .dice-grid {
        display: grid;
        grid-template-columns: repeat(4, 1fr);
        gap: 10px;
        margin-bottom: 20px;
    }

    .dice-btn {
        background-color: #6a1b9a;
        color: white;
        border: none;
        padding: 12px 5px;
        border-radius: 8px;
        font-size: 1rem;
        font-weight: bold;
        cursor: pointer;
        transition: background 0.3s, transform 0.1s;
        width: 100%;
    }

    .dice-btn:hover {
        background-color: #4a148c;
    }

    .dice-btn:active {
        transform: scale(0.95);
    }

    /* Inputy */
    .dice-input {
        width: 70px;
        padding: 8px;
        border-radius: 5px;
        border: 1px solid #555;
        background-color: #121212;
        color: white;
        text-align: center;
        font-size: 1.1rem;
        font-weight: bold;
        box-sizing: border-box;
    }

    /* Sekcja niestandardowa */
    .dice-custom-section {
        border-top: 1px solid #333;
        padding-top: 20px;
        display: flex;
        gap: 10px;
        justify-content: center;
        align-items: center;
    }
    
    .dice-custom-section .dice-input {
        width: 60px; /* Mniejsze dla min/max */
        font-size: 1rem;
    }

    .dice-btn-custom {
        background-color: #00796b;
        flex-grow: 1;
    }
    
    .dice-btn-custom:hover {
        background-color: #004d40;
    }

    /* Animacja */
    .dice-shake {
        animation: diceShake 0.5s cubic-bezier(.36,.07,.19,.97) both;
    }

    @keyframes diceShake {
        10%, 90% { transform: translate3d(-1px, 0, 0); }
        20%, 80% { transform: translate3d(2px, 0, 0); }
        30%, 50%, 70% { transform: translate3d(-4px, 0, 0); }
        40%, 60% { transform: translate3d(4px, 0, 0); }
    }
</style>

<div class="dice-widget-container">
    <h2>Generator Kości RPG</h2>

    <div class="dice-result-box">
        <div id="dice-result" class="dice-result-number">-</div>
        <div id="dice-label" class="dice-result-label">Wybierz ilość i rodzaj kości</div>
    </div>

    <div class="dice-count-row">
        <span class="dice-count-label">Liczba kości:</span>
        <input type="number" id="dice-count" class="dice-input" value="1" min="1" max="50">
    </div>

    <div class="dice-grid">
        <button class="dice-btn" onclick="runDiceRoll(4)">k4</button>
        <button class="dice-btn" onclick="runDiceRoll(6)">k6</button>
        <button class="dice-btn" onclick="runDiceRoll(8)">k8</button>
        <button class="dice-btn" onclick="runDiceRoll(10)">k10</button>
        <button class="dice-btn" onclick="runDiceRoll(12)">k12</button>
        <button class="dice-btn" onclick="runDiceRoll(20)">k20</button>
        <button class="dice-btn" onclick="runDiceRoll(100)" style="grid-column: span 2;">k100</button>
    </div>

    <div class="dice-custom-section">
        <input type="number" id="dice-min" class="dice-input" placeholder="Min" value="1">
        <input type="number" id="dice-max" class="dice-input" placeholder="Max" value="50">
        <button class="dice-btn dice-btn-custom" onclick="runCustomRoll()">Losuj Zakres</button>
    </div>
</div>

<script>
    const diceResultDisplay = document.getElementById('dice-result');
    const diceLabelDisplay = document.getElementById('dice-label');
    const diceCountInput = document.getElementById('dice-count');

    function getDiceRandomInt(min, max) {
        min = Math.ceil(min);
        max = Math.floor(max);
        return Math.floor(Math.random() * (max - min + 1)) + min;
    }

    function animateAndShowDice(totalValue, detailsText) {
        // Reset animacji
        diceResultDisplay.classList.remove('dice-shake');
        void diceResultDisplay.offsetWidth; 
        
        diceResultDisplay.innerText = "...";
        diceLabelDisplay.innerText = "Turla kości...";
        diceResultDisplay.classList.add('dice-shake');

        setTimeout(() => {
            diceResultDisplay.innerText = totalValue;
            diceLabelDisplay.innerText = detailsText;
        }, 500);
    }

    function runDiceRoll(sides) {
        let count = parseInt(diceCountInput.value);
        if (isNaN(count) || count < 1) count = 1;
        if (count > 100) count = 100; // Zabezpieczenie przed zacięciem przeglądarki

        let total = 0;
        let rolls = [];

        // Pętla rzutów
        for (let i = 0; i < count; i++) {
            let roll = getDiceRandomInt(1, sides);
            total += roll;
            rolls.push(roll);
        }

        // Formatowanie wyniku
        let labelText = "";
        if (count === 1) {
            labelText = `Wynik rzutu k${sides}`;
        } else {
            // Jeśli dużo rzutów, skróć opis
            if(count > 15) {
                labelText = `Suma ${count} rzutów k${sides}`;
            } else {
                labelText = `(${rolls.join(" + ")})`;
            }
        }

        animateAndShowDice(total, labelText);
    }

    function runCustomRoll() {
        // Dla "zakresu" zwykle rzuca się raz, ale użyjemy mnożnika jeśli użytkownik chce
        let count = parseInt(diceCountInput.value);
        if (isNaN(count) || count < 1) count = 1;

        const minInput = document.getElementById('dice-min');
        const maxInput = document.getElementById('dice-max');
        
        let min = parseInt(minInput.value);
        let max = parseInt(maxInput.value);

        if (isNaN(min) || isNaN(max)) {
            alert("Proszę wpisać poprawne liczby!");
            return;
        }
        if (min >= max) {
            alert("Min musi być mniejsze od Max!");
            return;
        }

        let total = 0;
        let rolls = [];

        for (let i = 0; i < count; i++) {
            let roll = getDiceRandomInt(min, max);
            total += roll;
            rolls.push(roll);
        }

        let labelText = "";
        if (count === 1) {
            labelText = `Losowa z zakresu ${min}-${max}`;
        } else {
            if(count > 15) {
                labelText = `Suma ${count} losowych liczb (${min}-${max})`;
            } else {
                labelText = `(${rolls.join(" + ")})`;
            }
        }

        animateAndShowDice(total, labelText);
    }
</script>