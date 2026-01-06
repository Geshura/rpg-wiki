---
title: Kostka
description: Maksymalnie rozbudowany przykład funkcji MkDocs Material.
icon: material/shimmer
status: new
---

<!-- Styles moved to css/kostka.css and loaded via mkdocs `extra_css` -->

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