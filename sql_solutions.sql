
-- SECTION A: HOTEL MANAGEMENT SYSTEM

-- Q1: Last booked room for each user
SELECT b.user_id, b.room_no
FROM bookings b
JOIN (
SELECT user_id, MAX(booking_date) AS last_booking
FROM bookings
GROUP BY user_id
) lb
ON b.user_id = lb.user_id AND b.booking_date = lb.last_booking;

-- Q2: Total billing per booking (November 2021)
SELECT
bc.booking_id,
SUM(bc.item_quantity * i.item_rate) AS total_bill
FROM booking_commercials bc
JOIN items i ON bc.item_id = i.item_id
WHERE DATE_FORMAT(bc.bill_date, '%Y-%m') = '2021-11'
GROUP BY bc.booking_id;

-- Q3: Bills in October 2021 with amount > 1000
SELECT
bc.bill_id,
SUM(bc.item_quantity * i.item_rate) AS bill_amount
FROM booking_commercials bc
JOIN items i ON bc.item_id = i.item_id
WHERE DATE_FORMAT(bc.bill_date, '%Y-%m') = '2021-10'
GROUP BY bc.bill_id
HAVING bill_amount > 1000;

-- Q4: Most & least ordered item per month (2021)
WITH item_orders AS (
SELECT
MONTH(bc.bill_date) AS month,
bc.item_id,
SUM(bc.item_quantity) AS total_qty
FROM booking_commercials bc
WHERE YEAR(bc.bill_date) = 2021
GROUP BY month, bc.item_id
),
ranked AS (
SELECT *,
RANK() OVER (PARTITION BY month ORDER BY total_qty DESC) AS max_rank,
RANK() OVER (PARTITION BY month ORDER BY total_qty ASC) AS min_rank
FROM item_orders
)
SELECT *
FROM ranked
WHERE max_rank = 1 OR min_rank = 1;

-- Q5: Second highest bill per month (2021)
WITH bill_values AS (
SELECT
MONTH(bc.bill_date) AS month,
bc.booking_id,
SUM(bc.item_quantity * i.item_rate) AS total_bill
FROM booking_commercials bc
JOIN items i ON bc.item_id = i.item_id
WHERE YEAR(bc.bill_date) = 2021
GROUP BY month, bc.booking_id
),
ranked AS (
SELECT *,
DENSE_RANK() OVER (PARTITION BY month ORDER BY total_bill DESC) AS rnk
FROM bill_values
)
SELECT *
FROM ranked
WHERE rnk = 2;

-- SECTION B: CLINIC MANAGEMENT SYSTEM

-- Q1: Revenue per sales channel
SELECT
sales_channel,
SUM(amount) AS revenue
FROM clinic_sales
WHERE YEAR(datetime) = 2021
GROUP BY sales_channel;

-- Q2: Top 10 customers
SELECT
uid,
SUM(amount) AS total_spent
FROM clinic_sales
WHERE YEAR(datetime) = 2021
GROUP BY uid
ORDER BY total_spent DESC
LIMIT 10;

-- Q3: Month-wise revenue, expense, profit
WITH revenue AS (
SELECT MONTH(datetime) AS month, SUM(amount) AS revenue
FROM clinic_sales
WHERE YEAR(datetime) = 2021
GROUP BY month
),
expense AS (
SELECT MONTH(datetime) AS month, SUM(amount) AS expense
FROM expenses
WHERE YEAR(datetime) = 2021
GROUP BY month
)
SELECT
r.month,
r.revenue,
e.expense,
(r.revenue - e.expense) AS profit,
CASE
WHEN (r.revenue - e.expense) > 0 THEN 'Profitable'
ELSE 'Not Profitable'
END AS status
FROM revenue r
JOIN expense e ON r.month = e.month;

-- Q4: Most profitable clinic per city
WITH profit_calc AS (
SELECT
c.city,
c.cid,
SUM(cs.amount) - COALESCE(SUM(e.amount), 0) AS profit
FROM clinics c
LEFT JOIN clinic_sales cs ON c.cid = cs.cid
LEFT JOIN expenses e ON c.cid = e.cid
AND MONTH(cs.datetime) = MONTH(e.datetime)
WHERE MONTH(cs.datetime) = 9 AND YEAR(cs.datetime) = 2021
GROUP BY c.city, c.cid
),
ranked AS (
SELECT *,
RANK() OVER (PARTITION BY city ORDER BY profit DESC) AS rnk
FROM profit_calc
)
SELECT *
FROM ranked
WHERE rnk = 1;

-- Q5: Second least profitable clinic per state
WITH profit_calc AS (
SELECT
c.state,
c.cid,
SUM(cs.amount) - COALESCE(SUM(e.amount), 0) AS profit
FROM clinics c
LEFT JOIN clinic_sales cs ON c.cid = cs.cid
LEFT JOIN expenses e ON c.cid = e.cid
AND MONTH(cs.datetime) = MONTH(e.datetime)
WHERE MONTH(cs.datetime) = 9 AND YEAR(cs.datetime) = 2021
GROUP BY c.state, c.cid
),
ranked AS (
SELECT *,
DENSE_RANK() OVER (PARTITION BY state ORDER BY profit ASC) AS rnk
FROM profit_calc
)
SELECT *
FROM ranked
WHERE rnk = 2;