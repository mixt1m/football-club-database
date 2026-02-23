# Запросы

## Запрос 1:
### Условие: Получить список фамилий всех игроков, чья позиция "Forward".
### π last_name σ (position = 'Forward') Player

## Запрос 2: 
### Условие: Найти всех игроков с зарплатой больше 5 000 000, и вывести их фамилии. 
### π last_name σ ( salary > 5000000 ( Player ⋈ Player.player_id = Contract.player_id Contract))
