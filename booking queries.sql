--Dealing With Nulls

UPDATE
	bookings
SET
	children = COALESCE (children, '0'),
	agent = COALESCE (agent, '0'),
	country = COALESCE (country, 'Unknown'),
	stays_in_weekend_nights = COALESCE (stays_in_weekend_nights, '0'),
    price= COALESCE(price, 
			 (SELECT
				ROUND(AVG(price) :: numeric, 2)
			 FROM 
				booking_view)
			);
	
	
	
--Dealing With Duplicates

DROP VIEW IF EXISTS booking_view;

CREATE VIEW booking_view
AS 
	SELECT
	*
	FROM	
		(SELECT *,
			ROW_NUMBER() OVER(PARTITION BY booking_id ORDER BY booking_id) AS rn
		FROM bookings
		 
		 ) AS subquery
	WHERE rn = 1;

--What is the overall cancellation rate for hotel bookings?

WITH Totalbookings AS(
	SELECT 
		COUNT(*) AS total_bookings
	FROM
		bookings_view
),
	CancelledBookings AS(
	SELECT 
		COUNT(*) AS totalcancellations
	FROM 
		bookings_view
	WHERE
		is_canceled > 0
)
SELECT 
	ROUND((CAST(CancelledBookings.totalcancellations AS FLOAT) * 100
		   / Totalbookings.total_bookings ) :: numeric, 2)
	AS cancellation_rate
	FROM 
		CancelledBookings, 
		Totalbookings;
	
-- Which Countries are the top contributors to hotel bookings?

SELECT 
	country,
	ROUND(SUM(price) :: numeric, 2) AS total_contributon
FROM 
	booking_view
GROUP BY 
	country
ORDER BY 
	total_contribution DESC
LIMIT 5;

--What are the main market segments booking the hotels, such as leisure or corporate?

SELECT 
	market_segment,
	ROUND(SUM(price) :: numeric, 2) AS total_contribution
FROM 
	bookings_view
WHERE 
	market_segment != 'Undefined'
GROUP BY 
	market_segment;

--Is there a relationship between deposit type (e.g., non-refundable, refundable) and the likelihood of cancellation?

WITH total_cancellations
AS
	(SELECT
		COUNT(is_canceled) AS total 
	FROM 
		bookings_view
	WHERE
		is_canceled > 0),
AS
	(SELECT 
		deposit_type, SUM(is_canceled) by_deposit
	FROM
		booking_view
	WHERE
		is_canceled > 0
	GROUP BY 
		deposit_type)
SELECT 
	deposit_type,
	(cancellations_by_deposit_type.by_deposit * 100)/ total_cancellations.total
AS
	Cancellation_rate
FROM 
	cancellations_by_deposit_type,
	total_cancellations;

--What meal options are most preferred by guests?

SELECT 
	meal,
	COUNT(*) Total_meals
FROM
	booking_view
GROUP BY
	meal
ORDER BY
	Total_meals DESC
LIMIT 
	3;

--Do bookings made through agents exhibit different cancellation rates or booking durations compared to direct bookings?
