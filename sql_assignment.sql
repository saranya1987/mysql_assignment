-- Display the first and last names of all actors from the table `actor`
USE sakila;
SELECT first_name,last_name FROM sakila.actor;

-- Display the first and last name of each actor in a single column
SELECT Concat(first_name,' ' ,last_name) AS 'Actor Name'
FROM sakila.actor;

-- find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe."
SELECT actor_id,first_name,last_name FROM sakila.actor WHERE first_name = 'Joe';

-- Find all actors whose last name contain the letters `GEN`
SELECT actor_id,first_name,last_name FROM sakila.actor WHERE last_name LIKE '%GEN%';

 -- Find all actors whose last names contain the letters `LI`
SELECT actor_id,first_name,last_name FROM sakila.actor WHERE last_name LIKE '%LI%' ORDER BY last_name,first_name;

-- display the `country_id` and `country` columns of Afghanistan, Bangladesh, and China
SELECT country_id,country FROM sakila.country WHERE country IN ( 'Afghanistan', 'Bangladesh', 'China' );

-- Add a `middle_name` column to the table `actor`
ALTER TABLE sakila.actor ADD COLUMN middle_name VARCHAR(30) AFTER first_name;

-- Change the data type of the `middle_name` column to `blobs`
SELECT * FROM sakila.actor;
ALTER TABLE sakila.actor MODIFY COLUMN middle_name blob;

-- delete the `middle_name` column
ALTER TABLE sakila.actor DROP COLUMN middle_name;

-- List the last names of actors, as well as how many actors have that last name
SELECT last_name, COUNT(last_name) AS 'Count'
FROM sakila.actor
GROUP BY last_name;

-- List last names of actors, but only for names that are shared by at least two actors
SELECT last_name, COUNT(last_name) AS cnt
FROM sakila.actor
GROUP BY last_name
HAVING (cnt > 1);

-- Change actor `HARPO WILLIAMS` in the `actor` table as `GROUCHO WILLIAMS`
UPDATE sakila.actor SET first_name= 'HARPO' WHERE first_name='GROUCHO' AND last_name='WILLIAMS';

-- Change the first name of the actor `HARPO` to `GROUCHO`. Otherwise, change the first name to `MUCHO GROUCHO`
UPDATE sakila.actor
SET first_name =
CASE WHEN first_name = 'HARPO' THEN 'GROUCHO'
ELSE 'MUCHO GROUCHO'
END WHERE actor_id = 172;

-- Recreate the schema of the `address` table
SHOW CREATE TABLE sakila.address;
DESCRIBE sakila.address;

-- `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`
SELECT staff.first_name, staff.last_name, address.address
FROM staff
INNER JOIN address ON address.address_id = staff.address_id;

-- `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`
SELECT * FROM sakila.actor;
SELECT payment.staff_id, staff.first_name, staff.last_name, sum(payment.amount)
FROM staff
INNER JOIN payment ON payment.staff_id = staff.staff_id
GROUP BY payment.staff_id;

-- List film and the number of actors using tables `film_actor` and `film`
SELECT title, COUNT(actor_id)
FROM film f
INNER JOIN film_actor fa ON f.film_id = fa.film_id
GROUP BY title;

-- Display Number of copies of the film `Hunchback Impossible` exist in the inventory system
SELECT title, COUNT(inventory_id)
FROM film f 
INNER JOIN inventory i ON f.film_id = i.film_id
WHERE title = 'Hunchback Impossible';

-- Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer
SELECT first_name, last_name, sum(amount)
FROM customer c
INNER JOIN payment p ON p.customer_id = c.customer_id
GROUP BY p.customer_id
ORDER BY last_name ASC;

-- Display the titles of movies starting with the letters `K` and `Q` whose language is English
SELECT title FROM film
WHERE language_id IN(SELECT language_id FROM language WHERE name = "English" ) 
AND (title LIKE "K%") OR (title LIKE "Q%");

-- Display all actors who appear in the film `Alone Trip`
SELECT first_name,last_name FROM actor WHERE actor_id IN(
	SELECT actor_id FROM film_actor WHERE film_id IN(
		SELECT film_id FROM film WHERE title = 'Alone Trip'));
        
-- Display the names and email addresses of all Canadian customers using joins
SELECT first_name, last_name, email 
FROM customer
JOIN address ON (customer.address_id = address.address_id)
JOIN city ON (address.city_id=city.city_id)
JOIN country ON (city.country_id=country.country_id)
WHERE country = 'Canada';

-- Display all movies categorized as famiy films
SELECT title FROM film WHERE film_id IN
	(SELECT film_id FROM film_category WHERE category_id IN
		(SELECT category_id FROM category WHERE name = 'Family'));
        
 -- Display the most frequently rented movies in descending order       
SELECT title,count(film.film_id) from film
JOIN inventory ON (film.film_id= inventory.film_id)
JOIN rental ON (inventory.inventory_id = rental.rental_id)
GROUP BY title
ORDER BY COUNT(film.film_id) DESC;

-- Display how much business, in dollars, each store brought in
SELECT store.store_id, SUM(payment.amount)
FROM store
JOIN staff ON store.store_id = staff.store_id
JOIN payment ON payment.staff_id = staff.staff_id
GROUP BY store.store_id
ORDER BY SUM(amount);

-- Display for each store its store ID, city, and country
SELECT store_id, city, country FROM store
JOIN address ON (store.address_id=address.address_id)
JOIN city ON (address.city_id=city.city_id)
JOIN country ON (city.country_id=country.country_id);

-- List the top five genres in gross revenue in descending order
SELECT name, SUM(amount) FROM category
JOIN film_category ON (category.category_id=film_category.category_id)
JOIN inventory ON (film_category.film_id=inventory.film_id)
JOIN rental ON (inventory.inventory_id=rental.inventory_id)
JOIN payment ON (rental.rental_id=payment.rental_id)
GROUP BY category.name ORDER BY SUM(amount)  LIMIT 5;

-- Create view for top five grossing genres
CREATE VIEW top_five_genres AS
SELECT name, SUM(amount) FROM category
JOIN film_category ON (category.category_id=film_category.category_id)
JOIN inventory ON (film_category.film_id=inventory.film_id)
JOIN rental ON (inventory.inventory_id=rental.inventory_id)
JOIN payment ON (rental.rental_id=payment.rental_id)
GROUP BY category.name ORDER BY SUM(amount)  LIMIT 5;

-- Display the top five grossing genres view
SELECT * FROM top_five_genres;

-- Drop the top five grossing genres view
DROP VIEW top_five_genres;