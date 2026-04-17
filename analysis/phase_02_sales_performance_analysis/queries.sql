							-- Business question 01--
-- Who are our best performing sales reps? How much revenue has each one generated, 
-- and how do they compare to the average?
SELECT 
    e.emp_id,
    CONCAT(e.first_name, ' ', e.last_name) 	 AS rep_name,
    e.job_title,
    COUNT(o.order_id)                        AS total_orders,
    SUM(o.total_amount)                      AS total_revenue,
    ROUND(AVG(o.total_amount), 2)            AS avg_order_value,
    ROUND(SUM(o.total_amount) / 
          SUM(SUM(o.total_amount)) OVER() * 100, 2) AS revenue_share_pct
FROM employees e
JOIN orders o ON e.emp_id = o.emp_id
WHERE e.dept_id = 3                          -- Sales dept only
  AND o.status = 'Completed'
GROUP BY e.emp_id, e.first_name, e.last_name, e.job_title
ORDER BY total_revenue DESC;


					-- Business question 02--
-- Who are our best performing sales reps? 
-- How much revenue has each one generated, and how do they compare to the average?

SELECT 
    DATE_FORMAT(o.order_date, '%Y-%m')       AS order_month,
    DATE_FORMAT(o.order_date, '%b %Y')       AS month_label,
    COUNT(o.order_id)                        AS total_orders,
    SUM(o.total_amount)                      AS monthly_revenue,
    ROUND(AVG(o.total_amount), 2)            AS avg_order_value,
    SUM(SUM(o.total_amount)) OVER (
        ORDER BY DATE_FORMAT(o.order_date, '%Y-%m')
    )                                        AS cumulative_revenue
FROM orders o
WHERE o.status = 'Completed'
GROUP BY DATE_FORMAT(o.order_date, '%Y-%m'), DATE_FORMAT(o.order_date, '%b %Y')
ORDER BY order_month;


							-- Business question 03--
-- How many orders fail to complete? 
-- Which specific reps have the most cancellations 
-- or pending orders stuck in the pipeline?


SELECT 
    status,
    COUNT(*)                                  AS order_count,
    ROUND(COUNT(*) * 100.0 / 
          (SELECT COUNT(*) FROM orders), 2)   AS percentage,
    ROUND(SUM(total_amount), 2)               AS total_value
FROM orders
GROUP BY status
ORDER BY order_count DESC;

SELECT 
    CONCAT(e.first_name, ' ', e.last_name)   AS rep_name,
    o.status,
    COUNT(o.order_id)                        AS order_count,
    ROUND(SUM(o.total_amount), 2)            AS value_at_risk
FROM orders o
JOIN employees e ON o.emp_id = e.emp_id
WHERE o.status IN ('Pending', 'Cancelled')
GROUP BY e.emp_id, e.first_name, e.last_name, o.status
ORDER BY order_count DESC;



						-- Business question 04 --
-- Do customers paying by Bank Transfer place larger orders? 
-- Should we encourage certain payment methods?

SELECT 
    payment_method,
    COUNT(*)                                  AS order_count,
    ROUND(SUM(total_amount), 2)               AS total_revenue,
    ROUND(AVG(total_amount), 2)               AS avg_order_value,
    ROUND(MIN(total_amount), 2)               AS min_order,
    ROUND(MAX(total_amount), 2)               AS max_order,
    ROUND(COUNT(*) * 100.0 / 
          (SELECT COUNT(*) FROM orders 
           WHERE status = 'Completed'), 2)    AS usage_pct
FROM orders
WHERE status = 'Completed'
GROUP BY payment_method
ORDER BY total_revenue DESC;


							-- Business question 05 -- 
-- The HR team gives every employee a performance score. 
-- For sales reps specifically — does a higher score actually mean more revenue? 
-- Or is the scoring system not aligned with business outcomes?

SELECT 
    CONCAT(e.first_name, ' ', e.last_name)   AS rep_name,
    e.performance_score,
    e.salary,
    COUNT(o.order_id)                        AS total_orders,
    ROUND(SUM(o.total_amount), 2)            AS total_revenue,
    ROUND(AVG(o.total_amount), 2)            AS avg_deal_size,
    CASE 
        WHEN e.performance_score >= 4.5 THEN 'Top performer'
        WHEN e.performance_score >= 4.0 THEN 'Good performer'
        WHEN e.performance_score >= 3.5 THEN 'Average performer'
        ELSE 'Needs improvement'
    END                                      AS performance_tier
FROM employees e
JOIN orders o ON e.emp_id = o.emp_id
WHERE e.dept_id = 3
  AND o.status = 'Completed'
GROUP BY e.emp_id, e.first_name, e.last_name, 
         e.performance_score, e.salary
ORDER BY e.performance_score DESC;

