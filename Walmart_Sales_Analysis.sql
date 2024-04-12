-- Creating database
create database WalmartSalesData;

-- Creating table
CREATE TABLE IF NOT EXISTS sales(
	invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(30) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    tax_pct FLOAT(6,4) NOT NULL,
    total DECIMAL(12, 4) NOT NULL,
    date DATETIME NOT NULL,
    time TIME NOT NULL,
    payment VARCHAR(15) NOT NULL,
    cogs DECIMAL(10,2) NOT NULL,
    gross_margin_pct FLOAT(11,9),
    gross_income DECIMAL(12, 4),
    rating FLOAT(2, 1)
);


-- Data cleaning
select * from sales;


-- ---------------------------------------------------------------------------
--                         Feature Engineering
-- ---------------------------------------------------------------------------


-- Adding time_of_day column
select
    time,
    (case
        when time between "00:00:00" and "12:00:00" then "Morning"
        when time between "12:00:01" and '16:00:00' then "Afternoon"
        else "Evening"
	end) as time_of_day
from sales;

alter table sales add column time_of_day varchar(20);

update sales
set time_of_day=(
case
	when time between "00:00:00" and "12:00:00" then "Morning"
	when time between "12:00:01" and '16:00:00' then "Afternoon"
	else "Evening"
end
);


-- Adding day of date
select date,
	   dayname(date) as day_name
from sales;

alter table sales add column day_name varchar(30);

update sales
set day_name=dayname(date);


-- Adding month of date
select date,
	   monthname(date) as month_name
from sales;

alter table sales add column month_name varchar(30);

update sales
set month_name=monthname(date);


-- --------------------------------------------------------------------------------
--                         Generic Questions
-- --------------------------------------------------------------------------------

# How many unique cities does the data have?
select distinct city from sales;


#In which city is each branch?
select distinct branch,city from sales ;

-- --------------------------------------------------------------------------------
--                         Product Related Questions
-- --------------------------------------------------------------------------------

# How many unique product lines does the data have?
select distinct product_line from sales;
select * from sales;


# What is the most common payment method?
select payment, count(payment) as count_payment
from sales
group by payment
order by count_payment desc;


# What is the most selling product line?
select product_line,sum(quantity) as most_sell_prod
from sales
group by product_line
order by most_sell_prod desc;


# What is the total revenue by month?
select 
	month_name as month,
    round(sum(total)) as revenue
from sales
group by month
order by revenue desc;


# What month had the largest COGS?
select 
	month_name as month,
    sum(cogs) as revenue_cogs
from sales
group by month
order by revenue_cogs desc;

# What product line had the largest revenue?
select 
	product_line, sum(total) as sum_prod
from sales
group by product_line
order by sum_prod desc;


# What is the city with the largest revenue?
select 
      city,sum(total) as city_total
from sales
group by city
order by city_total desc;


# What product line had the largest VAT?
select
      product_line,avg(tax_pct) as avg_tax
from sales
group by product_line
order by avg_tax desc;


# Fetch each product line and add a column to those product line 
# showing "Good", "Bad". Good if its greater than average sales
select 
     avg(quantity) as qty
from sales;

-- so the avg quantity is 5.49

select
     product_line,
     case
          when avg(quantity)>6 then "Gppd"
	 else
         "Bad"
	end as remark
from sales
group by product_line;


# Which branch sold more products than average product sold?
select 
	branch,sum(quantity) as qnty
from sales
group by branch
having sum(quantity) > (select avg(quantity) from sales);


# Which branch sold more products than average product sold?
select
	gender,product_line, count(gender) as cnt_gender
from sales
group by gender,product_line
order by cnt_gender desc;

# What is the average rating of each product line?
select 
	product_line,avg(rating) as avg_rate
from sales 
group by product_line
order by avg_rate desc;


-- --------------------------------------------------------------------------------
--                         Sales Related Questions
-- --------------------------------------------------------------------------------

# Number of sales made in each time of the day per weekday
select
	time_of_day,count(*) as total_sales
from sales
where day_name = "Sunday"
group by time_of_day 
order by total_sales DESC;


# Which of the customer types brings the most revenue?
select
	customer_type, sum(total) as cust_total
from sales
group by customer_type
order by cust_total desc;

# Which city has the largest tax percent/ VAT (Value Added Tax)?
select 
	city,avg(tax_pct)as avg_tax
from sales
group by city
order by avg_tax desc;


# Which customer type pays the most in VAT?
select 
	customer_type,avg(tax_pct) as avg_tax
from sales
group by customer_type
order by avg_tax desc;


-- --------------------------------------------------------------------------------
--                         Customer Related Questions
-- --------------------------------------------------------------------------------

# How many unique customer types does the data have?
select 
	distinct customer_type 
from sales;


# How many unique payment methods does the data have?
select 
	distinct payment
from sales;


# What is the most common customer type?
select 
	customer_type, count(*) as count
from sales
group by customer_type
order by count desc;


# Which customer type buys the most?
select 
	customer_type,
    count(*) 
from sales
group by customer_type;


# What is the gender of most of the customers?
select 
	gender,count(*) as gender_count
from sales
group by gender
order by gender_count desc;


# Which time of the day do customers give most ratings?
select 
	time_of_day, avg(rating) as avg_rate
from sales
group by time_of_day
order by avg_rate desc;


# Which day fo the week has the best avg ratings?
select 
	day_name, avg(rating) as avg_rate_day
from sales
group by day_name
order by avg_rate_day desc;


# Which day of the week has the best average ratings per branch?
select 
	day_name,count(day_name) as total_sale
from sales
where branch='B' -- enter A/B/C for respective branches
group by day_name
order by total_sale desc;