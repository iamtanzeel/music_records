select * from albums;

-- Who is the senior most employee based on the job title?
select * from employee
order by levels desc
limit 1;

-- Which countires have the most invoice?
select * from invoice;

select billing_country,count(*) as billing_count
from invoice
group by billing_country
order by billing_count desc;

-- What are top 3 values of total invoice?

select invoice_id,customer_id,billing_country,round(total,2) as total from invoice
order by total desc
limit 3;

-- Which city has the highest sum of invoice totals?

select billing_city,round(sum(total),2) as invoice_total from invoice
group by billing_city
order by invoice_total  desc
limit 3;

-- Which customer has spent the most money?
select * from customer;

SELECT invoice.customer_id, customer.first_name,customer.last_name, ROUND(SUM(invoice.total), 2) AS total
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
GROUP BY invoice.customer_id, customer.first_name,customer.last_name
ORDER BY total desc
limit 3;


-- Write a query to return the email,first name,last name of all Metal music listeners.

select * from genre;

select distinct email,first_name,last_name
from customer
join invoice on customer.customer_id = invoice.customer_id
join invoice_line on invoice.invoice_id = invoice_line.invoice_id
where track_id in (
					select track_id from track
                    join genre on track.genre_id = genre.genre_id
                    where genre.name = 'metal')
order by email;

-- The above query can be rewritten as:
select distinct email,first_name,last_name
from customer
join invoice on customer.customer_id = invoice.customer_id
where invoice.invoice_id in (
							select invoice_line.invoice_id
                            from invoice_line
                            join track on invoice_line.track_id = track.track_id
                            where track.track_id in ( select track.track_id 
												from track
                                                join genre on track.genre_id = genre.genre_id
                                                where genre.name = 'Metal'))
order by email;

 
 
 -- Write a query that returns names the Artist name and total track count of top 10 Metal bands
 
 
 select * from artist;
 select artist.artist_id,artist.name, count(artist.artist_id) as number_of_songs
 from track
 join albums on track.album_id = albums.album_id
 join artist on artist.artist_id = albums.artist_id
 join genre on genre.genre_id = track.genre_id
 where genre.name = 'Metal'
 group by artist.artist_id,artist.name
 order by number_of_songs desc
 limit 10;
 
-- Return all the track names that have a song length longer than average song length. Return the name and milliseconds for each track.

select * from track;

select name,milliseconds
from track 
where milliseconds > (
						select avg(milliseconds) 
                        from track)
order by milliseconds desc;



-- Find how much amount spent by each customer on artist. Write a query to return customer name, artist name and total spent

with best_selling_artist as (
	select artist.artist_id as artist_id,
			artist.name as artist_name,
            sum(invoice_line.unit_price*invoice_line.quantity ) as total_sales
            from invoice_line
            join track on track.track_id = invoice_line.track_id
            join albums on albums.album_id = track.album_id
            join artist on artist.artist_id = albums.artist_id
            group by artist_id,artist_name
            order by total_sales desc
            limit 1
	)
select c.customer_id,
		c.first_name,
        c.last_name,
        bsa.artist_name,
		sum(il.unit_price*il.quantity) as amount_spent
from invoice i 
join customer c on c.customer_id = i.customer_id
join invoice_line il on il.invoice_id = i.invoice_id
join track t on t.track_id = t.album_id
join albums alb on alb.album_id = t.album_id
join best_selling_artist bsa on bsa.artist_id = alb.artist_id
group by 1,2,3,4
order by 5 desc;
