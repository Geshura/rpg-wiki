---
title: "FAQ"
author: "Geshura"
tags: [markdown, dokumentacja, szablon]
description: "Ten plik zawiera demonstrację wszystkich kluczowych elementów składni Markdown."
---

# Nagłówek Poziomu 1 (Tytuł Główny)
Poniżej znajduje się tekst wprowadzający. To jest zwykły akapit tekstu. Możesz używać **pogrubienia**, *kursywy*, ***pogrubionej kursywy*** oraz ~~przekreślenia~~.

## Spis Treści (Opcjonalny)
1. [Tekst i Formatowanie](#tekst-i-formatowanie)
2. [Listy](#listy)
3. [Kod](#kod)
4. [Tabele](#tabele)
5. [Media i Linki](#media-i-linki)
6. [Elementy Zaawansowane](#elementy-zaawansowane)

---

## Nagłówek Poziomu 2
### Nagłówek Poziomu 3
#### Nagłówek Poziomu 4
##### Nagłówek Poziomu 5
###### Nagłówek Poziomu 6

---

## Listy

### Lista Wypunktowana
* Element pierwszy
* Element drugi
  * Podpunkt poziomu 2
  * Podpunkt poziomu 2
    * Podpunkt poziomu 3
- Można używać myślników
+ Lub plusów

### Lista Numerowana
1. Pierwszy krok
2. Drugi krok
3. Trzeci krok
   1. Podkrok A
   2. Podkrok B

### Lista Zadań (Task List)
- [x] Zadanie ukończone
- [ ] Zadanie do zrobienia
- [ ] Zadanie w toku

### Lista Definicji (Wspierana w niektórych edytorach)
Termin 1
: Definicja terminu pierwszego.

Termin 2
: Definicja terminu drugiego.

---

## Kod

### Kod w linii
Użyj funkcji `print("Hello World")` aby wyświetlić tekst.

### Blok Kodu (Z kolorowaniem składni)

```python
def powitanie(imie):
    """Funkcja witająca użytkownika"""
    return f"Cześć, {imie}!"

print(powitanie("Gemini"))