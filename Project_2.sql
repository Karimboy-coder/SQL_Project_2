-- ══════════════════════════════════════════════════════════════
--  Author:Karimboy
--  Description: ADVANCED FLIGHT & AIRLINE PERFORMANCE PROJECT
-- ══════════════════════════════════════════════════════════════

-- ============================================
-- 1. CREATE TABLES
-- ============================================

CREATE TABLE airlines (
    airline_id INT PRIMARY KEY,
    airline_name VARCHAR(100),
    country VARCHAR(50),
    fleet_size INT,
    safety_rating FLOAT -- 1 to 5
);

CREATE TABLE airports (
    airport_code VARCHAR(3) PRIMARY KEY,
    airport_name VARCHAR(100),
    city VARCHAR(100),
    country VARCHAR(50),
    hub_quality_index FLOAT -- 1 to 100
);

CREATE TABLE flights (
    flight_id INT PRIMARY KEY,
    airline_id INT,
    origin_airport VARCHAR(3),
    destination_airport VARCHAR(3),
    distance_km INT,
    fuel_consumption_kg FLOAT,
    passengers_count INT,
    ticket_revenue_usd DECIMAL(15,2),
    departure_delay_min INT,
    FOREIGN KEY (airline_id) REFERENCES airlines(airline_id),
    FOREIGN KEY (origin_airport) REFERENCES airports(airport_code),
    FOREIGN KEY (destination_airport) REFERENCES airports(airport_code)
);

-- ============================================
-- 2. SAMPLE DATA INSERTION
-- ============================================

INSERT INTO airlines VALUES 
(1, 'Uzbekistan Airways', 'Uzbekistan', 35, 4.2),
(2, 'Emirates', 'UAE', 260, 4.9),
(3, 'Lufthansa', 'Germany', 280, 4.7),
(4, 'Delta Airlines', 'USA', 850, 4.5),
(5, 'Qatar Airways', 'Qatar', 230, 4.8);

INSERT INTO airports VALUES 
('TAS', 'Tashkent International', 'Tashkent', 'Uzbekistan', 75.0),
('DXB', 'Dubai International', 'Dubai', 'UAE', 98.5),
('FRA', 'Frankfurt Airport', 'Frankfurt', 'Germany', 92.0),
('JFK', 'John F. Kennedy', 'New York', 'USA', 89.0),
('DOH', 'Hamad International', 'Doha', 'Qatar', 97.0);

INSERT INTO flights VALUES 
(101, 1, 'TAS', 'DXB', 2190, 12000, 180, 45000.00, 15),
(102, 2, 'DXB', 'JFK', 11000, 95000, 350, 420000.00, 5),
(103, 3, 'FRA', 'TAS', 4600, 32000, 220, 88000.00, 0),
(104, 2, 'DXB', 'FRA', 4800, 35000, 310, 150000.00, 45),
(105, 5, 'DOH', 'JFK', 12300, 105000, 320, 390000.00, 10),
(106, 1, 'TAS', 'FRA', 4700, 33000, 160, 72000.00, 20);

-- ============================================
-- 3. ADVANCED ANALYTICS QUERIES
-- ============================================

-- 1. FUEL EFFICIENCY AND REVENUE ANALYSIS

SELECT 
    f.flight_id, 
    a.airline_name,
    (f.ticket_revenue_usd / f.distance_km) AS revenue_per_km,
    (f.fuel_consumption_kg / f.passengers_count) AS fuel_efficiency_per_passenger
FROM flights f
JOIN airlines a ON f.airline_id = a.airline_id
ORDER BY revenue_per_km DESC;

-- 2. MARKET SHARE ANALYSIS

SELECT 
    airline_name,
    SUM(ticket_revenue_usd) OVER(PARTITION BY airline_name) as airline_total_rev,
    ROUND(SUM(ticket_revenue_usd) OVER(PARTITION BY airline_name) * 100.0 / SUM(ticket_revenue_usd) OVER(), 2) as market_share_percent
FROM flights f
JOIN airlines a ON f.airline_id = a.airline_id;

-- 3. DELAYED FLIGHT IMPACT MODEL
WITH DelayStats AS (
    SELECT 
        airline_id,
        AVG(departure_delay_min) as avg_delay,
        COUNT(*) as total_flights
    FROM flights
    GROUP BY airline_id
)
SELECT 
    a.airline_name, 
    d.avg_delay,
    RANK() OVER (ORDER BY d.avg_delay DESC) as unreliability_rank
FROM DelayStats d
JOIN airlines a ON d.airline_id = a.airline_id;

-- 4. ROUTE CONNECTIVITY MATRIX

SELECT 
    f1.origin_airport AS start_point,
    f1.destination_airport AS transfer_point,
    f2.destination_airport AS final_destination,
    (f1.distance_km + f2.distance_km) AS total_journey_km
FROM flights f1
JOIN flights f2 ON f1.destination_airport = f2.origin_airport
WHERE f1.origin_airport <> f2.destination_airport;

-- 5. FLIGHT CARBON FOOTPRINT SCORE 

SELECT 
    airline_name,
    SUM(fuel_consumption_kg * 3.15) / SUM(passengers_count) AS carbon_per_passenger_score
FROM flights f
JOIN airlines a ON f.airline_id = a.airline_id
GROUP BY airline_name
HAVING SUM(passengers_count) > 0;

-- 6. FINAL MASTER SCORE 

SELECT 
    a.airline_name,
    (
        (a.safety_rating * 20) + 
        (100 - AVG(f.departure_delay_min)) * 0.3 + 
        (SUM(f.ticket_revenue_usd) / SUM(f.distance_km)) * 10
    ) AS global_performance_index
FROM airlines a
LEFT JOIN flights f ON a.airline_id = f.airline_id
GROUP BY a.airline_id, a.airline_name, a.safety_rating
ORDER BY global_performance_index DESC;

-- ============================================
-- END OF PROJECT: AVIATION ANALYTICS
-- ============================================