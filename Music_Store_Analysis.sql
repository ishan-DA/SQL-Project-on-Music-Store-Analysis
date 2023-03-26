-- Q1. Who is the senior most employee based on job title?


SELECT *
FROM employee
ORDER BY levels DESC
LIMIT 1;


-- Q2. Which countries have the most invoices?


SELECT billing_country, COUNT(*) AS most_invoices
FROM invoice
GROUP BY billing_country
ORDER BY most_invoices DESC;


-- Q3. What are top 3 values of total invoice?


SELECT total
FROM invoice
ORDER BY total DESC
LIMIT 3;


/* Q4. Which city has the best customers?
	   We would like to throw a promotional Music Festival in the city we made the most money. 
	   Write a query that returns one city that has the highest sum of invoice totals. 
	   Returns both the city name & sum of all invoice totals.	*/
	   
	   
SELECT billing_city, SUM(total) AS invoice_totals
FROM invoice
GROUP BY billing_city
ORDER BY invoice_totals DESC;


/* Q5. Who is the best customer? The customer who has spent the most money will be declared the best customer.
	   Write a query that returns the person who has spent the most money.		*/
	   
	   
SELECT c.customer_id, c.first_name, c.last_name, SUM(i.total) AS max_money_spent
FROM invoice i
JOIN customer c
ON i.customer_id = c.customer_id
GROUP BY c.customer_id
ORDER BY max_money_spent DESC
LIMIT 1;


/* Q6. Write a query to return the email, first name, last name & genre of all rock music listeners.
	   Return your list ordered alphabetically by email starting with 'A'	*/
	   
	     
SELECT DISTINCT c.email, c.first_name, c.last_name
FROM customer c
JOIN invoice i
ON c.customer_id = i.customer_id
JOIN invoice_line il
ON i.invoice_id = il.invoice_id
WHERE track_id IN (
	SELECT track_id
	FROM track t
	JOIN genre g
	ON t.genre_id = g.genre_id
	WHERE g.name LIKE 'Rock'
)
ORDER BY c.email;


/*	Q7. Let’s invite the artists who have written the most rock in our dataset. 
	    Write a query that returns the Artist name and total track count of the total 10 rock bands.	*/


SELECT ar.artist_id, ar.name, COUNT(ar.artist_id) AS no_of_songs
FROM track t
JOIN album al
ON al.album_id = t.album_id
JOIN artist ar
ON ar.artist_id = al.artist_id
JOIN genre g
ON g.genre_id = t.genre_id
WHERE g.name LIKE 'Rock'
GROUP BY ar.artist_id
ORDER BY no_of_songs DESC
LIMIT 10;



/*	Q8. Return all the track names that have a song length longer than the average song length.
		Return the name and millisecond for each track. Order by the song length with the longest songs listed first.	*/


SELECT name, milliseconds
FROM track
WHERE milliseconds > (
	SELECT AVG(milliseconds) avg_length
	FROM track
)
ORDER BY milliseconds DESC;


/*	Q9. Find how much amount spent by each customer on artists? 
		Write a query to return customer name, artist name and total spent.		*/		
		

WITH best_artist AS (
	SELECT ar.artist_id AS artist_id, ar.name AS artist_name,
	SUM(il.unit_price * il.quantity) AS total_sales
	FROM invoice_line il
	JOIN track t ON t.track_id = il.track_id
	JOIN album al ON al.album_id = t.album_id
	JOIN artist ar ON ar.artist_id = al.artist_id
	GROUP BY ar.artist_id
	ORDER BY total_sales DESC
	LIMIT 1
)
SELECT c.customer_id, c.first_name, c.last_name, ba.artist_name,
SUM(il.unit_price * il.quantity) AS amount_spent
FROM invoice i
JOIN customer c
ON c.customer_id = i.customer_id
JOIN invoice_line il
ON il.invoice_id = i.invoice_id
JOIN track t
ON t.track_id = il.track_id
JOIN  album al 
ON al.album_id = t.album_id
JOIN best_artist ba
ON ba.artist_id = al.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;


/*	Q10. We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres.	*/


WITH popular_genre AS 
(
    SELECT COUNT(il.quantity) AS purchases, c.country, g.name, g.genre_id, 
	ROW_NUMBER() OVER(PARTITION BY c.country 
	ORDER BY COUNT(il.quantity) DESC) AS row_no 
    FROM invoice_line il
	JOIN invoice i ON i.invoice_id = il.invoice_id
	JOIN customer c ON c.customer_id = i.customer_id
	JOIN track t ON t.track_id = il.track_id
	JOIN genre g ON g.genre_id = t.genre_id
	GROUP BY 2,3,4
	ORDER BY 2, 1 DESC
)
SELECT * FROM popular_genre WHERE row_no <= 1;


/*	Q11. Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount.	*/


WITH customer_with_country AS (
		SELECT c.customer_id, c.first_name, c.last_name, i.billing_country, SUM(i.total) AS total_spending,
	    ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(i.total) DESC) AS row_no 
		FROM invoice i
		JOIN customer c ON c.customer_id = i.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 4 ASC,5 DESC)
SELECT * FROM customer_with_country WHERE row_no <= 1;