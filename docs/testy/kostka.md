---
title: Kostka
description: Maksymalnie rozbudowany przykład funkcji MkDocs Material.
icon: material/shimmer
status: new
---

<style>
    .dice-widget-container {
        font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        background-color: #1e1e1e;
        color: #ffffff;
        padding: 2rem;
        border-radius: 15px;
        box-shadow: 0 10px 30px rgba(0,0,0,0.5);
        text-align: center;
        width: 100%;
        max-width: 500px; /* Szerszy kontener dla formuły */
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
        min-height: 100px;
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

    .dice-result-details {
        font-size: 0.9rem;
        color: #aaa;
        margin-top: 10px;
        word-wrap: break-word;
        max-width: 100%;
        font-family: monospace; /* Czcionka stała dla czytelności */
    }

    /* Pole formuły */
    .dice-input-container {
        display: flex;
        margin-bottom: 15px;
        gap: 5px;
    }

    .dice-formula-input {
        width: 100%;
        padding: 15px;
        border-radius: 8px;
        border: 1px solid #555;
        background-color: #121212;
        color: #ffca28;
        font-size: 1.2rem;
        font-weight: bold;
        text-align: center;
        box-sizing: border-box;
        font-family: monospace;
    }

    /* Przyciski sterujące */
    .dice-controls {
        display: flex;
        gap: 10px;
        margin-bottom: 15px;
    }

    .btn-clear {
        background-color: #d32f2f;
        flex: 1;
    }
    .btn-clear:hover { background-color: #b71c1c; }

    .btn-roll {
        background-color: #00796b;
        flex: 3; /* Większy przycisk */
        font-size: 1.2rem;
    }
    .btn-roll:hover { background-color: #004d40; }

    /* Siatka kości */
    .dice-grid {
        display: grid;
        grid-template-columns: repeat(4, 1fr);
        gap: 8px;
    }

    .dice-btn {
        background-color: #6a1b9a;
        color: white;
        border: none;
        padding: 15px 5px;
        border-radius: 8px;
        font-size: 1rem;
        font-weight: bold;
        cursor: pointer;
        transition: background 0.2s, transform 0.1s;
        width: 100%;
    }

    .dice-btn:hover { background-color: #4a148c; }
    .dice-btn:active { transform: scale(0.95); }

    /* Modyfikatory */
    .dice-mod-btn {
        background-color: #424242;
        color: #ddd;
    }
    .dice-mod-btn:hover { background-color: #616161; }

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
    <h2>Kalkulator RPG</h2>

    <div class="dice-result-box">
        <div id="dice-result" class="dice-result-number">0</div>
        <div id="dice-details" class="dice-result-details">Wpisz formułę (np. 2k20+5)</div>
    </div>

    <div class="dice-input-container">
        <input type="text" id="dice-formula" class="dice-formula-input" placeholder="np. 2k6 + 10" value="2k20">
    </div>

    <div class="dice-controls">
        <button class="dice-btn btn-clear" onclick="clearFormula()">C</button>
        <button class="dice-btn btn-roll" onclick="processFormula()">RZUĆ!</button>
    </div>

    <div class="dice-grid">
        <button class="dice-btn" onclick="addToFormula('k4')">k4</button>
        <button class="dice-btn" onclick="addToFormula('k6')">k6</button>
        <button class="dice-btn" onclick="addToFormula('k8')">k8</button>
        <button class="dice-btn" onclick="addToFormula('k10')">k10</button>
        
        <button class="dice-btn" onclick="addToFormula('k12')">k12</button>
        <button class="dice-btn" onclick="addToFormula('k20')">k20</button>
        <button class="dice-btn" onclick="addToFormula('k100')">k100</button>
        <button class="dice-btn dice-mod-btn" onclick="addToFormula('+')">+</button>
        
        <button class="dice-btn dice-mod-btn" onclick="addToFormula('1')">1</button>
        <button class="dice-btn dice-mod-btn" onclick="addToFormula('2')">2</button>
        <button class="dice-btn dice-mod-btn" onclick="addToFormula('5')">5</button>
        <button class="dice-btn dice-mod-btn" onclick="addToFormula('10')">10</button>
    </div>
</div>

<script>
    const formulaInput = document.getElementById('dice-formula');
    const resultDisplay = document.getElementById('dice-result');
    const detailsDisplay = document.getElementById('dice-details');

    // Dodawanie tekstu do pola
    function addToFormula(val) {
        const current = formulaInput.value;
        // Sprytne dodawanie plusa jeśli trzeba
        if (['k', '1', '2', '5'].includes(val[0]) && current.length > 0 && !current.endsWith('+') && !current.endsWith(' ')) {
             // Jeśli wpisujesz 'k20' a w polu jest już 'k6', dodaj '+' automatycznie
             // (Uproszczona logika, można pisać ręcznie plusa)
        }
        formulaInput.value += val;
        formulaInput.focus();
    }

    function clearFormula() {
        formulaInput.value = '';
        resultDisplay.innerText = '0';
        detailsDisplay.innerText = 'Wyczyszczono';
    }

    function getRandomInt(min, max) {
        return Math.floor(Math.random() * (max - min + 1)) + min;
    }

    // GŁÓWNA LOGIKA PARSOWANIA
    function processFormula() {
        let text = formulaInput.value.toLowerCase().replace(/\s/g, ''); // Usuń spacje
        if (!text) return;

        // Reset animacji
        resultDisplay.classList.remove('dice-shake');
        void resultDisplay.offsetWidth;
        resultDisplay.classList.add('dice-shake');
        resultDisplay.innerText = "...";

        setTimeout(() => {
            try {
                calculate(text);
            } catch (e) {
                resultDisplay.innerText = "Błąd";
                detailsDisplay.innerText = "Niepoprawna formuła";
            }
        }, 400);
    }

    function calculate(text) {
        // Rozdzielamy po plusach i minusach, zachowując operatory
        // Regex: szuka [liczba]k[liczba] LUB [liczba]
        // Uproszczone: zamieniamy '-' na '+-' żeby sumować wszystko
        let cleanText = text.replace(/-/g, '+-');
        let parts = cleanText.split('+').filter(p => p !== '');

        let globalTotal = 0;
        let detailsLog = [];

        parts.forEach(part => {
            let multiplier = 1;
            if (part.startsWith('-')) {
                multiplier = -1;
                part = part.substring(1);
            }

            if (part.includes('k') || part.includes('d')) {
                // To jest kostka (np. 2k20 lub k6)
                let splitDice = part.split(/[kd]/);
                let count = splitDice[0] === "" ? 1 : parseInt(splitDice[0]); // Puste przed 'k' oznacza 1
                let sides = parseInt(splitDice[1]);

                let subTotal = 0;
                let rolls = [];
                for(let i=0; i<count; i++) {
                    let r = getRandomInt(1, sides);
                    subTotal += r;
                    rolls.push(r);
                }
                
                // Mnożnik (dla odejmowania kostek, rzadkie ale możliwe)
                subTotal *= multiplier;
                globalTotal += subTotal;

                // Formatowanie logów: 2k20[15, 3]
                let sign = multiplier < 0 ? "-" : "+";
                // Jeśli to pierwszy element i jest dodatni, nie pokazuj plusa w logu
                if (detailsLog.length === 0 && sign === "+") sign = ""; 
                
                detailsLog.push(`${sign}${count}k${sides}[${rolls.join(',')}]`);

            } else {
                // To jest stała liczba (np. 5 lub 10)
                let val = parseInt(part);
                if (!isNaN(val)) {
                    val *= multiplier;
                    globalTotal += val;
                    let sign = val >= 0 ? "+" : "";
                    if (detailsLog.length === 0 && sign === "+") sign = "";
                    detailsLog.push(`${sign}${val}`);
                }
            }
        });

        resultDisplay.innerText = globalTotal;
        detailsDisplay.innerText = detailsLog.join(' ');
    }
</script>