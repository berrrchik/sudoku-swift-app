# Sudoku App

Приложение для игры в Судоку с использованием **Swift** и **SwiftUI**. Это проект с несколькими уровнями сложности, поддержкой подсказок, заметок и проверкой решения.

---

## Особенности
- Генерация головоломок с уровнями сложности: Лёгкий, Средний, Тяжёлый.
- Возможность оставлять заметки в ячейках.
- Подсказки для сложных головоломок.
- Функция отмены последнего действия.
- Отображение правильного ответа.

---

## Структура проекта

### Основные компоненты
1. **`ContentView`**  
   Главный экран с переключением между выбором сложности и игровым процессом.

2. **`DifficultySelectionView`**  
   Экран выбора уровня сложности.

3. **`SudokuGameView`**  
   Основной экран игры. Здесь размещена сетка судоку и элементы управления.

4. **`SudokuGridView`**  
   Сетка 9x9, отображающая значения, заметки и выделение ячеек.

5. **`SudokuCellView`**  
   Отдельная ячейка с поддержкой отображения значений, заметок и рамок.

### Логика игры
6. **`SudokuViewModel`**  
   Логика обработки событий игры, включая:
   - Обновление ячеек.
   - Управление заметками.
   - Генерация и проверка решений.
   - История изменений (для отмены действий).

7. **`SudokuGenerator`**  
   Генератор головоломок, создающий сетку и решение в зависимости от уровня сложности.

8. **`SudokuModel`**  
   Модель данных для представления головоломки и её решения.

---

## Установка
1. Убедитесь, что у вас установлен **Xcode 14** или выше.
2. Склонируйте репозиторий:
   ```bash
   git clone https://github.com/berrrchik/sudoku-swift-app
3. Откройте проект в Xcode и запустите.

---

## Скриншоты

<p align="center">
   <img src="https://github.com/user-attachments/assets/9109a060-1236-414f-b284-68433be1e3de" alt="Экран выбора сложности" width="32%" />
   <img src="https://github.com/user-attachments/assets/5b8485aa-7883-471e-9413-01bc5f3aa475" alt="Отображение доски" width="32%" />
   <img src="https://github.com/user-attachments/assets/d46862ab-1c16-40c7-b49d-32150842eeaf" alt="Отображение судоку" width="32%" />
   <img src="https://github.com/user-attachments/assets/beed7904-7fd8-477e-a671-edd283c2c4a3" alt="Отображение выбранной ячейки" width="32%" />
   <img src="https://github.com/user-attachments/assets/a967d3e9-0a88-41fc-8efd-4c323fc892a4" alt="Режим заметок" width="32%" />
   <img src="https://github.com/user-attachments/assets/959c1d55-ae61-4287-9202-4f61d7d04516" alt="Решение" width="32%" />
</p>


