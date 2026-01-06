---
title: FAQ
description: Maksymalnie rozbudowany przykład funkcji MkDocs Material.
icon: material/information-box
status: deprecated
---

[TOC]

# Admonitions

Ten dokument prezentuje wszystkie dostępne style bloków (Admonitions) używane w naszej dokumentacji.

---

## Komunikaty standardowe
Te bloki służą do przekazywania informacji technicznych, zasad gry oraz ostrzeżeń dla Mistrza Gry.

### abstract
!!! abstract "Podsumowanie Rozdziału"
    W tej sekcji omówimy mechaniki rzutów obronnych oraz system ekwipunku. Zapoznanie się z tymi zasadami jest kluczowe przed rozpoczęciem kampanii.
	
### info
!!! info "Wersja Systemu"
    Zasady opierają się na silniku **Core Rules v2.5**. Niektóre mechaniki mogą różnić się od poprzedniej edycji.
	
### tip
!!! tip "Wskazówka dla MG"
    Zawsze pozwalaj graczom na kreatywne rozwiązanie problemu, nawet jeśli nie przewidziałeś tego w scenariuszu. *Zasada "Tak, i..."*.
	
### success
!!! success "Awans na Poziom"
    Jeśli gracze ukończą ten rozdział, powinni otrzymać wystarczającą ilość punktów doświadczenia, aby awansować na **Poziom 3**.
	
### question
!!! question "Jak obliczyć Klasę Pancerza?"
    KP to suma: `Bazowe 10` + `Modyfikator Zręczności` + `Bonus z Pancerza`.
	
### example
!!! example "Przykład Rzutu Ataku"
    Gracz rzuca k20 i otrzymuje wynik **14**. Dodaje swój modyfikator Siły (+3) oraz Biegłość (+2).
    **Całkowity wynik to 19.**
	
### warning
!!! warning "Zmiana Zasad"
    Pamiętaj, że w tej strefie magia działa inaczej. Wszystkie zaklęcia leczące mają o połowę mniejszą skuteczność.
	
### failure
!!! failure "Test Nieudany"
    Jeśli gracz wyrzuci **1** na kości (Krytyczna Porażka), jego broń zostaje upuszczona lub uszkodzona.
	
### danger
!!! danger "Strefa Śmierci"
    Wkraczasz na terytorium **Czerwonego Smoka**. Postacie poniżej 5 poziomu zginą tu natychmiastowo bez odpowiedniej ochrony przed ogniem.
	
### bug
!!! bug "Znany Błąd Mechaniki"
    Kombinacja atutu *Szybkie Dobycie* z *Dwuręcznością* powoduje błąd w turach. Zostanie to naprawione w erracie 1.2.

### quote
!!! quote "Zasada Złota"
    > "Mistrz Gry ma zawsze rację. Nawet jeśli jej nie ma."
    > — *Podręcznik Gracza, str. 4*

---

## Komunikaty customowe
Te bloki służą do budowania klimatu, opisywania zadań, przedmiotów i bestiariusza.

### quest
!!! quest "Zadanie Główne: Cienie Przeszłości"
    Musisz odnaleźć zaginiony artefakt w ruinach starej katedry.
    
    * **Zleceniodawca:** Arcybiskup
    * **Cel:** Odzyskaj *Kielich Światła*
    * **Nagroda:** 1000 sztuk złota i tytuł Paladyna.

### loc
!!! loc "Lokacja: Zrujnowana Katedra"
    Mroczna, gotycka budowla majaczy na tle burzowego nieba.
    **Wskazówka:** Wejście do katakumb znajduje się za ołtarzem.

### npc
!!! npc "Strażnik Krypty (Yorick)"
    Garbata postać w kapturze, podpierająca się łopatą.
    > *"Nikt stąd nie wychodzi, panie... przynajmniej nie w jednym kawałku."*

### grave
!!! grave "Zapomniany Grobowiec"
    Tu spoczywa Święty Alistair.
    *Inskrypcja głosi: "Tylko w ciemności ujrzysz światło".*

### boss
!!! boss "Upadły Paladyn"
    | Cecha | Wartość |
    | :--- | :--- |
    | **PŻ** | 150 |
    | **KP** | 18 (Płytowa) |
    
    **Zdolność:** *Aura Strachu* - każdy w promieniu 10 stóp musi wykonać rzut na Wolę (DC 15).

### spell
!!! spell "Mroczny Pocisk"
    **Krąg:** 2
    **Obrażenia:** 4k6 (Nekrotyczne)
    Wiązka czarnej energii, która wysysa siły witalne z celu.

### weapon
!!! weapon "Ostrze Zdrajcy (Miecz Długi)"
    **Typ:** Broń Magiczna (+1)
    **Obrażenia:** 1k8 + 1
    Ostrze pulsuje czerwoną poświatą w obecności wrogów.

### potion
!!! potion "Eliksir Niewidzialności"
    **Czas trwania:** 1 godzina
    Płyn jest całkowicie przezroczysty, jak woda, ale gęsty jak syrop.

### loot
!!! loot "Skrzynia Bossa"
    W środku znajdujesz:
    * 💎 **Rubin** (Wartość: 500 gp)
    * 📜 **Stary Pergamin** (Mapa)
    * 💰 **sakiewkę złota**

### note
!!! note "Znaleziona Notatka"
    *"Oni nadchodzą... słyszę ich w ścianach. Niech bogowie mają nas w opiece."*
    — Ostatni wpis w dzienniku.

---

## Komunikaty interaktywne

??? boss "Ukryty Przeciwnik (Spoiler)"
    To wcale nie był posąg! To **Gargulec**!
    Atakuje z zaskoczenia, gdy gracze odwrócą się plecami.

!!! loot ""
    *(Pusty blok z samą ikoną)* Znalazłeś drobne monety na posadzce.