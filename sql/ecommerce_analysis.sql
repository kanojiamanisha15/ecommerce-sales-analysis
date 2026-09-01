-- ============================================
-- E-commerce Sales & Customer Analysis
-- ============================================

CREATE TABLE ecommerce_sales (
    order_id VARCHAR(20),
    order_date DATE,
    customer_id VARCHAR(20),
    customer_name VARCHAR(100),
    gender VARCHAR(20),
    age INTEGER,
    city VARCHAR(100),
    state VARCHAR(100),
    region VARCHAR(50),
    product_id VARCHAR(20),
    product_name VARCHAR(100),
    category VARCHAR(100),
    quantity INTEGER,
    unit_price NUMERIC(12,2),
    discount NUMERIC(5,2),
    sales NUMERIC(14,2),
    cost NUMERIC(14,2),
    profit NUMERIC(14,2)
);

-- 1. Overall Business Metrics

SELECT COUNT(*) FROM ecommerce_sales;

SELECT * FROM ecommerce_sales LIMIT 10;

select SUM(sales) as total_revenue from ecommerce_sales;

select SUM(profit) as total_profit from ecommerce_sales;

select count(distinct order_id) as total_orders from ecommerce_sales;

select count(distinct customer_id) as total_customers from ecommerce_sales;

-- 2. Category Analysis

SELECT category, sum(sales) as total_sales from ecommerce_sales group by category order by total_sales desc;

select category, sum(profit) as total_profit from ecommerce_sales group by category order by total_profit desc;

select category, sum(sales) as total_sales, sum(profit) as total_profit from ecommerce_sales group by category order by total_sales desc;

select category, sum(sales) as total_sales, sum(profit) as total_profit, round(sum(profit)/nullif(sum(sales), 0)*100) as profit_margin_percentage from ecommerce_sales group by category order by profit_margin_percentage desc;

-- 3. Regional Analysis

SELECT region, sum(sales) as total_sales from ecommerce_sales group by region order by total_sales desc;

select region, sum(sales) as total_sales, sum(profit) as total_profit from ecommerce_sales group by region order by total_sales desc;

SELECT city , sum(sales) as total_sales from ecommerce_sales group by city order by total_sales desc;

select city, sum(sales) as total_sales, sum(profit) as total_profit from ecommerce_sales group by city order by total_sales desc;

-- 4. Monthly Sales Analysis

select date_trunc('month', order_date) as month, sum(sales) as total_sales from ecommerce_sales group by month order by month;

select date_trunc('month', order_date) as month, sum(sales) as total_sales from ecommerce_sales group by month order by total_sales desc limit 1;

select date_trunc('month', order_date) as month, sum(profit) as total_profit from ecommerce_sales group by month order by total_profit desc limit 1;

-- 5. Product Analysis

select product_name, sum(sales) as total_sales from ecommerce_sales group by product_name order by total_sales desc limit 10;

select product_name, sum(profit) as total_profit from ecommerce_sales group by product_name order by total_profit desc limit 10;

-- 6. Customer Analysis

select count(distinct customer_id) as total_customers from ecommerce_sales;

select customer_id, customer_name, count(distinct order_id) as total_orders, sum(sales) as total_sales from ecommerce_sales group by customer_id, customer_name order by total_sales desc limit 10;

select customer_id, customer_name, count(distinct order_id) as total_orders from ecommerce_sales group by customer_id, customer_name order by total_orders desc;

select count(*) as repeat_customers from (select customer_id from ecommerce_sales group by customer_id having count(distinct order_id)>1) as customer_orders;

select count(*) as one_time_customers from (select customer_id from ecommerce_sales group by customer_id having count(distinct order_id)=1) as customer_orders;

select round(count(*) filter (where order_count>1)::numeric/count(*)*100, 2) as repeat_customer_percentage from (select customer_id, count(distinct order_id) as order_count)

select round(sum(sales)/count(distinct customer_id), 2) as average_revenue_per_customer from ecommerce_sales;

select customer_id, customer_name, sum(sales) as total_sales, case when sum(sales)>=100000 then 'High Value' when sum(sales)>=50000 then 'Medium Value' else 'Low Value' end as customer_segment from ecommerce_sales group by customer_id, customer_name order by total_sales desc;

with customer_segments as (select customer_id, sum(sales) as total_sales, case when sum(sales)>=100000 then 'High Value' when sum(sales)>=50000 then 'Medium Value' else 'Low Value' end as customer_segment from ecommerce_sales group by customer_id)

select customer_segment, count(*) as customer_count from customer_segments group by customer_segment order by customer_count desc;

with customer_segments as (select customer_id, sum(sales) as total_sales, case when sum(sales)>=100000 then 'High Value' when sum(sales)>=50000 then 'Medium Value' else 'Low Value' end as customer_segment from ecommerce_sales group by customer_id)

select customer_segment, count(*) as customer_count, round(sum(total_sales), 2) as total_revenue from customer_segments group by customer_segment order by total_revenue desc;

select customer_id, customer_name, sum(sales) as total_sales, sum(profit) as total_profit from ecommerce_sales group by customer_id, customer_name order by total_profit desc limit 10;

-- ============================================
-- 7. Product Analysis
-- ============================================

select product_name , sum(quantity) as total_quantity_sold, sum(sales) as total_sales from ecommerce_sales group by product_name order by total_sales  desc limit 10;

select product_name , sum(quantity) as total_quantity_sold, sum(sales) as total_sales, sum(profit) as total_profit from ecommerce_sales group by product_name order by total_profit desc limit 10;

select product_name , sum(sales) as total_sales, sum(profit) as total_profit, round(sum(profit)/nullif(sum(sales), 0)*100, 2) as profit_margin_percentage from ecommerce_sales group by product_name order by profit_margin_percentage desc limit 10;

select category, product_name, sum(sales) as total_sales, sum(profit) as total_profit from ecommerce_sales group by category, product_name order by total_sales desc;

select distinct discount from ecommerce_sales order by discount desc;

select discount*100 as discount_percentage, count(distinct order_id) as total_orders, sum(sales) as total_sales, sum(profit) as total_profit, round(avg(profit), 2) as average_profit from ecommerce_sales group by discount order by discount;

select discount*100 as discount_percentage, sum(sales) as total_sales, sum(profit) as total_profit, round(sum(profit)/nullif(sum(sales), 0)*100, 2) as profit_margin_percentage from ecommerce_sales group by discount order by discount;

with product_performance as (select product_name, sum(profit) as total_profit, sum(sales) as total_sales, round(sum(profit)/nullif(SUM(sales), 0)*100, 2) as profit_margin from ecommerce_sales group by product_name) 
select * from product_performance where total_sales >(select AVG(total_sales) from product_performance) and profit_margin <(select avg(profit_margin) from product_performance) order by total_sales desc;

select product_name, round(avg(discount)*100, 2) as average_discount, sum(sales) as total_sales, SUM(profit) AS total_profit from ecommerce_sales group by product_name order by average_discount desc;

with product_sales as (select product_name, sum(sales) as total_sales from ecommerce_sales group by product_name)
select product_name, total_sales, rank() over (order by total_sales desc) as sales_rank from product_sales order by sales_rank;

with product_sales as (select category, product_name, sum(sales) as total_sales from ecommerce_sales group by category, product_name)
select category, product_name, total_sales, rank() over (partition by category order by total_sales desc) as category_rank from product_sales order by category, category_rank;

with product_sales as (select category, product_name, sum(sales) as total_sales from ecommerce_sales group by category, product_name),
ranked_products as (select category, product_name, total_sales, rank() over (partition by category order by total_sales desc) as category_rank from product_sales)
select category, product_name, total_sales from ranked_products where category_rank=1 order by category;


