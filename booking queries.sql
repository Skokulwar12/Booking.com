--Dealing With Nulls

UPDATE bookings
SET children = COALESCE (children, '0'),
	agent = COALESCE (agent, '0'),
	country = COALESCE (country, 'Unknown'),
	stays_in_weekend_nights = COALESCE (stays_in_weekend_nights, '0'),
    price= COALESCE(price, 
			 (SELECT ROUND(AVG(price) :: numeric, 2) FROM booking_view)
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


