INSERT INTO football_club.owners (name, nationality, purchase_date) VALUES
('Роман', 'Русский', '2003-07-01'),
('Вова', 'ОАЭ', '2008-09-01'),
('Станислав', 'Русский', '2020-01-15');


INSERT INTO football_club.stadiums (name, capacity, address) VALUES
('Стэмфорд Бридж', 40834, 'Лондон'),
('Этихад', 55097, 'Манчестер'),
('Ак Барс Арена', 45379, 'Казань');



INSERT INTO football_club.football_clubs (name, country, city, owner_id, staduim_id) VALUES
('Челси', 'Англия', 'Лондон', 1, 1),
('Манчестер Сити', 'Англия', 'Манчестер', 2, 2),
('Рубин', 'Россия', 'Казань', 3, 3);


INSERT INTO football_club.sponsors (club_id, start_date, end_date, amount, type) VALUES
(1, '2023-01-01', '2025-12-31', 50000000.00, 'Титульный спонсор'),
(2, '2022-07-01', '2026-06-30', 75000000.00, 'Технический спонсор'),
(3, '2024-01-01', '2024-12-31', 10000000.00, 'Официальный партнер');


INSERT INTO football_club.fun_shop (address, club_id) VALUES
('Лондон', 1),
('Манчестер', 2),
('Казань', 3);


INSERT INTO football_club.products (name, type, price, count, shop_id, height, width, length) VALUES
('Форма', 'Одежда', 4500.00, 50, 1, 70, 50, 5),
('Форма', 'Одежда', 4200.00, 35, 2, 70, 50, 5),
('Шарф', 'Аксессуар', 1200.00, 100, 3, 150, 30, 3);


INSERT INTO football_club.tournament (name, region, format) VALUES
('Лига Чемпионов УЕФА', 'Европа', 'плей-офф'),
('Лига Европы УЕФА', 'Европа', 'Групповой этап'),
('Кубок Англии', 'Англия', 'Плей-офф');


INSERT INTO football_club.league (name, country, tier) VALUES
('Английская Премьер-Лига', 'Англия', 1),
('Чемпионшип', 'Англия', 2),
('Российская Премьер-Лига', 'Россия', 1);


INSERT INTO football_club.participation (club_id, tournament_id, liague_id, season, final_position) VALUES
(1, 1, 1, '2024/2025', 1),
(2, 2, 1, '2024/2025', 2),
(3, 3, 3, '2024/2025', 3);


INSERT INTO football_club.players (first_name, date_of_birth, nationality, position, market_value, club_id) VALUES
('Джон', '1990-05-15', 'Английский', 'Защитник', 15000000.00, 1),
('Кевин', '1991-06-28', 'Бельгийский', 'Полузащитник', 80000000.00, 2),
('Алексей', '1995-03-12', 'Русский', 'Нападающий', 10000000.00, 3);


INSERT INTO football_club.contracts (player_id, club_id, start_date, end_date, salary) VALUES
(1, 1, '2022-07-01', '2025-06-30', 120000.00),
(2, 2, '2023-01-15', '2027-06-30', 300000.00),
(3, 3, '2024-01-01', '2026-06-30', 50000.00);


INSERT INTO football_club.staff (first_name, date_of_birth, salary, club_id) VALUES
('Томас', '1973-08-29', 80000.00, 1),
('Пеп', '1971-01-18', 95000.00, 2),
('Игорь', '1974-05-14', 40000.00, 3);


INSERT INTO football_club.medical_staff (staff_id, specialization) VALUES
(1, 'Главный физиотерапевт'),
(2, 'Спортивный врач'),
(3, 'Массажист');


INSERT INTO football_club.coaching_staff (staff_id, role, license) VALUES
(1, 'Главный тренер', 'UEFA Pro'),
(2, 'Главный тренер', 'UEFA Pro'),
(3, 'Тренер вратарей', 'UEFA A');


INSERT INTO football_club.administrative_staff (staff_id, department, job_title) VALUES
(1, 'Футбольная администрация', 'Менеджер клуба'),
(2, 'Финансовый отдел', 'Финансовый директор'),
(3, 'Отдел продаж', 'Менеджер по продажам');