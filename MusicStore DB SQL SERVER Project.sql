--Q1: Who is the senior most employee based on job title?

SELECT TOP 1 first_name,last_name,title,levels
FROM employee
ORDER BY levels DESC;

--Q2: Which countries have the most Invoices?

SELECT COUNT (*) invoice_counts ,billing_country
FROM invoice
GROUP BY billing_country
ORDER BY invoice_counts DESC;

-- Q3: What are top 3 values of total invoice?

SELECT  TOP 3 billing_country, total
FROM invoice
ORDER BY total DESC;

--Q4: Which city has the best customers? We would like to throw a promotional Music 
--Festival in the city we made the most money. 
--Write a query that returns one city that has the highest sum of invoice totals. 
--Return both the city name & sum of all invoice totals

SELECT TOP 1 billing_city, SUM (TOTAL) AS invoice_totals
FROM invoice
GROUP BY billing_city
ORDER BY invoice_totals DESC;

--Q5: Who is the best customer? The customer who has spent the most money will 
--be declared the best customer. 
--Write a query that returns the person who has spent the most money.


SELECT TOP 1 customer_id, first_name, last_name, total_amount
FROM (
    SELECT customer.customer_id, first_name, last_name, SUM(invoice.total) AS total_amount
    FROM customer
    INNER JOIN invoice ON customer.customer_id = invoice.customer_id
    GROUP BY customer.customer_id, first_name, last_name
) AS subquery
ORDER BY total_amount DESC;


--Q1: Write query to return the email, first name, last name, & Genre of all 
--Rock Music listeners. 
--Return your list ordered alphabetically by email starting with A. 

SELECT first_name,last_name,email,genre.name as genre_name
FROM customer
inner join invoice
on customer.customer_id=invoice.customer_id
inner join invoice_line
on invoice.invoice_id=invoice_line.invoice_id
inner join track
on invoice_line.track_id=track.track_id
inner join genre
on track.genre_id=genre.genre_id
where genre.name = 'rock'
group by first_name,last_name, email, genre.name
order by email

--Q2: Let's invite the artists who have written the most rock music in our dataset.
--Write a query that returns the Artist name and total track count of the top 10 rock bands.

SELECT TOP 10 artist.artist_id, artist.name, COUNT (albums.artist_id) AS 'Number_of_Songs'
FROM track
INNER JOIN albums
ON track.album_id=albums.album_id
INNER JOIN  genre
ON track.genre_id=genre.genre_id
INNER JOIN artist
ON artist.artist_id=albums.artist_id
WHERE genre.name LIKE 'ROCK'
GROUP BY artist.name,artist.artist_id
ORDER BY 'Number_of_Songs' DESC

--Q3: Return all the track names that have a song length longer than the average song length. 
--Return the Name and Milliseconds for each track. Order by the song length with the 
--longest songs listed first

SELECT name,milliseconds
FROM track
WHERE TRACK.milliseconds >= (SELECT AVG(MILLISECONDS) FROM TRACK)
ORDER BY milliseconds DESC


-- Q1: Find how much amount spent by each customer on artists? 
--Write a query to return customer name, artist name and total spent

SELECT customer.first_name AS CUSTOMER_FIRST_NAME, customer.last_name,artist.name AS ARTIST_NAME,
SUM(invoice_line.quantity*invoice_line.unit_price) AS TOTAL_SPENT
FROM TRACK
JOIN invoice_line
ON invoice_line.track_id=track.track_id
join invoice
ON invoice.invoice_id=invoice_line.invoice_id
JOIN customer
ON INVOICE.customer_id=customer.customer_id
JOIN albums
ON TRACK.album_id=albums.album_id
JOIN artist
ON artist.artist_id=albums.artist_id
GROUP BY customer.customer_id,customer.first_name, customer.last_name,artist.name
ORDER BY TOTAL_SPENT DESC

--Q2: We want to find out the most popular music Genre for each country. 
--We determine the most popular genre as the genre with the highest amount of purchases. 
--Write a query that returns each country along with the top Genre. For countries where 
--the maximum number of purchases is shared return all Genres.

WITH GenrePurchases AS (
SELECT invoice.billing_country AS Country, genre.name, COUNT(INVOICE.TOTAL) AS TotalPurchases,
ROW_NUMBER() OVER (PARTITION BY invoice.billing_country
ORDER BY COUNT(TOTAL) DESC ) AS GENRERANK
FROM invoice
INNER JOIN
invoice_line ON invoice.invoice_id = invoice_line.invoice_id
INNER JOIN
track ON invoice_line.track_id = track.track_id
INNER JOIN
genre ON track.genre_id = genre.genre_id
GROUP BY invoice.billing_country, genre.name)

SELECT Country,name,TotalPurchases
FROM GenrePurchases
WHERE GENRERANK=1
ORDER BY Country

-- Q3: Write a query that determines the customer that has spent the most on 
--music for each country. 
--Write a query that returns the country along with the top customer and how much they spent. 
--For countries where the top amount spent is shared, provide all customers who spent this amount.

WITH TOPCUSTOMER AS (
SELECT invoice.billing_country AS COUNTRY, customer.first_name AS FIRST_NAME,
customer.last_name AS LAST_NAME,SUM (invoice_line.quantity*invoice_line.unit_price)
AS Totalspent,
ROW_NUMBER() OVER (PARTITION BY INVOICE.BILLING_COUNTRY
ORDER BY sum(invoice_line.quantity*invoice_line.unit_price) DESC ) AS NO1CUSTOMER
FROM invoice
INNER JOIN customer
ON Customer.customer_id=invoice.customer_id
INNER JOIN invoice_line
ON invoice.invoice_id=invoice_line.invoice_id
GROUP BY invoice.billing_country, customer.first_name,customer.last_name)
SELECT COUNTRY,FIRST_NAME,LAST_NAME,Totalspent
FROM TOPCUSTOMER
WHERE NO1CUSTOMER>=1
ORDER BY COUNTRY