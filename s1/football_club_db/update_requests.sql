UPDATE football_club.players 
SET market_value = market_value * 1.25  
WHERE player_id = 2; 


UPDATE football_club.contracts 
SET end_date = '2028-06-30',
    salary = salary * 1.15 
WHERE player_id = 1; 


UPDATE football_club.stadiums 
SET capacity = 60000
WHERE staduim_id = 2; 


UPDATE football_club.staff 
SET salary = salary * 1.20 
WHERE staff_id = 3;  