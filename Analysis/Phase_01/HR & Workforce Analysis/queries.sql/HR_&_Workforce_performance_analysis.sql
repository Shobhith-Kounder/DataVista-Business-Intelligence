-- ============================================================
-- PHASE 1 — HR & Workforce Analytics
-- Q1: Department Headcount & Salary Breakdown
-- ============================================================
-- Business Question:
--   How many employees are in each department?
--   What is the average, minimum, and maximum salary per dept?
--   Which department carries the highest total payroll cost?
--   This tells leadership WHERE the company's people budget is going.
--
-- Tables Used  : employees, departments
-- Key Columns  : dept_id, salary, is_active
-- Filter       : Active employees only (is_active = TRUE)
-- ============================================================

USE company;

-- PART A: Headcount and salary stats per department
SELECT
    d.dept_name,
    d.location,
    COUNT(e.emp_id)                             AS headcount,
    ROUND(AVG(e.salary), 2)                     AS avg_salary,
    MIN(e.salary)                               AS min_salary,
    MAX(e.salary)                               AS max_salary,
    ROUND(SUM(e.salary), 2)                     AS total_payroll,
    ROUND(SUM(e.salary) /
          SUM(SUM(e.salary)) OVER () * 100, 2)  AS payroll_share_pct
FROM departments d
LEFT JOIN employees e
       ON d.dept_id = e.dept_id
      AND e.is_active = TRUE
GROUP BY d.dept_id, d.dept_name, d.location
ORDER BY total_payroll DESC;

-- ============================================================
-- PART B: Job title breakdown within each department
--         Useful for understanding seniority distribution
SELECT
    d.dept_name,
    e.job_title,
    COUNT(*)                                    AS employee_count,
    ROUND(AVG(e.salary), 2)                     AS avg_salary
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id
WHERE e.is_active = TRUE
GROUP BY d.dept_name, e.job_title
ORDER BY d.dept_name, avg_salary DESC;

-- ============================================================
-- INSIGHT TO LOOK FOR:
--   Which dept has highest total_payroll vs fewest people?
--     → High avg salary dept (Engineering likely)
--   payroll_share_pct shows budget concentration
--   Part B reveals if a dept is top-heavy (lots of seniors)
--     vs bottom-heavy (lots of juniors)
--
-- EXPORT AS: p1_q1_headcount_salary.csv  (Part A result)
--            p1_q1_job_titles.csv        (Part B result)
-- ============================================================




-- ============================================================
-- PHASE 1 — HR & Workforce Analytics
-- Q2: Performance Score vs Salary — Is Pay Fair?
-- ============================================================
-- Business Question:
--   Do employees with higher performance scores earn more?
--   Are there underpaid high-performers the company risks losing?
--   Are there overpaid low-performers draining the budget?
--   This is one of the most impactful HR insights you can surface.
--
-- Tables Used  : employees, departments
-- Key Columns  : performance_score, salary, dept_id
-- Special      : CASE WHEN for performance tiers
--                Window function for dept-level avg comparison
-- ============================================================

-- PART A: Every employee with their performance tier
--         and whether they are over/under paid vs dept average
SELECT
    CONCAT(e.first_name, ' ', e.last_name)      AS employee_name,
    d.dept_name,
    e.job_title,
    e.performance_score,
    e.salary,
    ROUND(AVG(e.salary)
          OVER (PARTITION BY e.dept_id), 2)     AS dept_avg_salary,
    ROUND(e.salary - AVG(e.salary)
          OVER (PARTITION BY e.dept_id), 2)     AS salary_vs_dept_avg,
    CASE
        WHEN e.performance_score >= 4.5 THEN 'Top Performer'
        WHEN e.performance_score >= 4.0 THEN 'Good Performer'
        WHEN e.performance_score >= 3.5 THEN 'Average Performer'
        ELSE                                    'Needs Improvement'
    END                                         AS performance_tier,
    CASE
        WHEN e.performance_score >= 4.5
             AND e.salary < AVG(e.salary) OVER (PARTITION BY e.dept_id)
             THEN 'UNDERPAID HIGH PERFORMER'
        WHEN e.performance_score < 3.5
             AND e.salary > AVG(e.salary) OVER (PARTITION BY e.dept_id)
             THEN 'OVERPAID LOW PERFORMER'
        ELSE 'Fairly positioned'
    END                                         AS pay_fairness_flag
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id
WHERE e.is_active = TRUE
ORDER BY e.performance_score DESC, e.salary DESC;

-- ============================================================

-- PART B: Summary by performance tier
--         How many in each tier, what do they earn on avg?
SELECT
    CASE
        WHEN performance_score >= 4.5 THEN 'Top Performer'
        WHEN performance_score >= 4.0 THEN 'Good Performer'
        WHEN performance_score >= 3.5 THEN 'Average Performer'
        ELSE                               'Needs Improvement'
    END                                         AS performance_tier,
    COUNT(*)                                    AS employee_count,
    ROUND(AVG(salary), 2)                       AS avg_salary,
    ROUND(MIN(salary), 2)                       AS min_salary,
    ROUND(MAX(salary), 2)                       AS max_salary,
    ROUND(AVG(performance_score), 2)            AS avg_score
FROM employees
WHERE is_active = TRUE
GROUP BY
    CASE
        WHEN performance_score >= 4.5 THEN 'Top Performer'
        WHEN performance_score >= 4.0 THEN 'Good Performer'
        WHEN performance_score >= 3.5 THEN 'Average Performer'
        ELSE                               'Needs Improvement'
    END
ORDER BY avg_score DESC;

-- ============================================================
-- INSIGHT TO LOOK FOR:
--   PART A — Filter pay_fairness_flag for 'UNDERPAID HIGH PERFORMER'
--     → These are flight risks. HR should act on this list.
--   PART B — Is avg_salary clearly higher for Top Performers?
--     → If not, the compensation system is broken.
--   salary_vs_dept_avg shows relative position within team
--     → Positive = paid above team average, negative = below
--
-- EXPORT AS: p1_q2_performance_salary.csv   (Part A)
--            p1_q2_tier_summary.csv          (Part B)
-- ============================================================


-- ============================================================
-- PHASE 1 — HR & Workforce Analytics
-- Q3: Hiring Trends & Employee Tenure Analysis
-- ============================================================
-- Business Question:
--   Which year had the most new hires?
--   Is the company growing its workforce or stabilising?
--   Are newer employees being paid more than long-tenured ones?
--   Tenure vs salary can reveal salary compression — a common
--   problem where new hires earn as much as 5-year veterans.
--
-- Tables Used  : employees, departments
-- Key Columns  : hire_date, salary, emp_id
-- Special      : TIMESTAMPDIFF for tenure in years
-- ============================================================

USE company;

-- PART A: Hiring count by year
--         Shows growth trajectory of the company
SELECT
    YEAR(hire_date)        AS hire_year,
    COUNT(*)               AS new_hires,
    ROUND(AVG(salary), 2)  AS avg_starting_salary,
    MIN(salary)            AS min_salary_that_year,
    MAX(salary)            AS max_salary_that_year
FROM employees
GROUP BY YEAR(hire_date)
ORDER BY hire_year;

-- ============================================================

-- PART B: Tenure buckets — how long have employees been here?
SELECT
    CASE
        WHEN TIMESTAMPDIFF(YEAR, hire_date, CURDATE()) < 1
             THEN '0 — Less than 1 year'
        WHEN TIMESTAMPDIFF(YEAR, hire_date, CURDATE()) < 3
             THEN '1 — 1 to 3 years'
        WHEN TIMESTAMPDIFF(YEAR, hire_date, CURDATE()) < 5
             THEN '2 — 3 to 5 years'
        WHEN TIMESTAMPDIFF(YEAR, hire_date, CURDATE()) < 8
             THEN '3 — 5 to 8 years'
        ELSE '4 — 8+ years'
    END                                         AS tenure_bucket,
    COUNT(*)                                    AS employee_count,
    ROUND(AVG(salary), 2)                       AS avg_salary,
    ROUND(AVG(performance_score), 2)            AS avg_performance_score
FROM employees
WHERE is_active = TRUE
GROUP BY
    CASE
        WHEN TIMESTAMPDIFF(YEAR, hire_date, CURDATE()) < 1
             THEN '0 — Less than 1 year'
        WHEN TIMESTAMPDIFF(YEAR, hire_date, CURDATE()) < 3
             THEN '1 — 1 to 3 years'
        WHEN TIMESTAMPDIFF(YEAR, hire_date, CURDATE()) < 5
             THEN '2 — 3 to 5 years'
        WHEN TIMESTAMPDIFF(YEAR, hire_date, CURDATE()) < 8
             THEN '3 — 5 to 8 years'
        ELSE '4 — 8+ years'
    END
ORDER BY tenure_bucket;

-- ============================================================

-- PART C: Full employee list with exact tenure
--         Useful for the Power BI scatter plot (tenure vs salary)
SELECT
    CONCAT(e.first_name, ' ', e.last_name)      AS employee_name,
    d.dept_name,
    e.job_title,
    e.hire_date,
    TIMESTAMPDIFF(YEAR, e.hire_date, CURDATE()) AS tenure_years,
    e.salary,
    e.performance_score
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id
WHERE e.is_active = TRUE
ORDER BY tenure_years DESC;

-- ============================================================
-- INSIGHT TO LOOK FOR:
--   PART A — Is avg_starting_salary going up each year?
--     → Rising = wage inflation, company paying more for new talent
--   PART B — Do 8+ year employees earn significantly more
--             than 1-3 year employees?
--     → If NOT → salary compression problem
--   PART C — Use as scatter plot: X = tenure, Y = salary
--     → Should show upward trend if compensation is fair
--
-- EXPORT AS: p1_q3_hiring_by_year.csv   (Part A)
--            p1_q3_tenure_buckets.csv    (Part B)
--            p1_q3_tenure_salary.csv     (Part C)
-- ============================================================

-- ============================================================
-- PHASE 1 — HR & Workforce Analytics
-- Q4: Attrition Analysis — Who Left and Is There a Pattern?
-- ============================================================
-- Business Question:
--   Which employees are no longer active (is_active = FALSE)?
--   Which departments are losing people?
--   Were the employees who left high performers or low performers?
--   Were they underpaid compared to their department average?
--   Finding patterns in attrition helps prevent future losses.
--
-- Tables Used  : employees, departments
-- Key Columns  : is_active, performance_score, salary, dept_id
-- Filter       : is_active = FALSE (inactive/left employees)
-- ============================================================

USE company;

-- PART A: All employees who have left — full profile
SELECT
    CONCAT(e.first_name, ' ', e.last_name)      AS employee_name,
    d.dept_name,
    e.job_title,
    e.hire_date,
    TIMESTAMPDIFF(YEAR, e.hire_date, CURDATE()) AS tenure_at_exit_years,
    e.salary,
    e.performance_score,
    CASE
        WHEN e.performance_score >= 4.5 THEN 'Top Performer'
        WHEN e.performance_score >= 4.0 THEN 'Good Performer'
        WHEN e.performance_score >= 3.5 THEN 'Average Performer'
        ELSE                               'Needs Improvement'
    END                                         AS performance_tier,
    ROUND(AVG(e2.salary), 2)                    AS dept_avg_salary,
    ROUND(e.salary -
          AVG(e2.salary), 2)                    AS salary_vs_dept_avg
FROM employees e
JOIN departments d  ON e.dept_id  = d.dept_id
JOIN employees e2   ON e2.dept_id = e.dept_id
                   AND e2.is_active = TRUE
WHERE e.is_active = FALSE
GROUP BY
    e.emp_id, e.first_name, e.last_name,
    d.dept_name, e.job_title, e.hire_date,
    e.salary, e.performance_score
ORDER BY e.performance_score DESC;

-- ============================================================

-- PART B: Attrition count and avg profile by department
SELECT
    d.dept_name,
    COUNT(e.emp_id)                             AS employees_left,
    ROUND(AVG(e.salary), 2)                     AS avg_salary_of_leavers,
    ROUND(AVG(e.performance_score), 2)          AS avg_score_of_leavers,
    ROUND(AVG(
        TIMESTAMPDIFF(YEAR, e.hire_date, CURDATE())
    ), 1)                                       AS avg_tenure_at_exit
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id
WHERE e.is_active = FALSE
GROUP BY d.dept_name
ORDER BY employees_left DESC;

-- ============================================================

-- PART C: Attrition rate per department
--         (leavers as % of total headcount in that dept)
SELECT
    d.dept_name,
    COUNT(CASE WHEN e.is_active = FALSE THEN 1 END)     AS leavers,
    COUNT(CASE WHEN e.is_active = TRUE  THEN 1 END)     AS active,
    COUNT(e.emp_id)                                     AS total,
    ROUND(
        COUNT(CASE WHEN e.is_active = FALSE THEN 1 END)
        * 100.0 / COUNT(e.emp_id), 1
    )                                                   AS attrition_rate_pct
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id
GROUP BY d.dept_name
ORDER BY attrition_rate_pct DESC;

-- ============================================================
-- INSIGHT TO LOOK FOR:
--   PART A — Were leavers underpaid vs dept avg? (salary_vs_dept_avg)
--     → Consistent negative values = pay-driven attrition
--   Were leavers high performers? (performance_tier)
--     → If yes → company is losing its best people, serious problem
--   PART B — Which dept lost the most people?
--   PART C — attrition_rate_pct: anything above 10% is a red flag
--
-- EXPORT AS: p1_q4_leavers_profile.csv      (Part A)
--            p1_q4_attrition_by_dept.csv    (Part B)
--            p1_q4_attrition_rate.csv       (Part C)
-- ============================================================

-- ============================================================
-- PHASE 1 — HR & Workforce Analytics
-- Q5: Monthly Payroll Cost & Salary Hike Impact
-- ============================================================
-- Business Question:
--   What was the total payroll cost each month (Oct–Jan)?
--   How much did the December (+5%) and January (+10%) hikes
--   actually add to the monthly payroll bill?
--   Which department's costs rose the most in absolute terms?
--   This directly answers: "What did the raises cost us?"
--
-- Tables Used  : salaries, employees, departments
-- Key Columns  : salary, from_date, to_date, emp_id
-- Note         : The salaries table has one row per employee
--                per month. Use from_date to group by month.
-- ============================================================

USE company;

-- PART A: Total company payroll by month
--         Shows the exact cost impact of the hikes
SELECT
    DATE_FORMAT(s.from_date, '%Y-%m')  AS payroll_month,
    DATE_FORMAT(s.from_date, '%b %Y')  AS month_label,
    COUNT(DISTINCT s.emp_id)           AS employees_paid,
    ROUND(SUM(s.salary), 2)            AS total_payroll,
    ROUND(AVG(s.salary), 2)            AS avg_salary
FROM salaries s
GROUP BY
    DATE_FORMAT(s.from_date, '%Y-%m'),
    DATE_FORMAT(s.from_date, '%b %Y')
ORDER BY payroll_month;

-- ============================================================

-- PART B: Month-over-month payroll change
--         Calculates the exact rupee/dollar increase each month
SELECT
    month_label,
    total_payroll,
    LAG(total_payroll) OVER (ORDER BY payroll_month) AS prev_month_payroll,
    ROUND(
        total_payroll -
        LAG(total_payroll) OVER (ORDER BY payroll_month), 2
    )                                           AS payroll_increase,
    ROUND(
        (total_payroll -
         LAG(total_payroll) OVER (ORDER BY payroll_month))
        / LAG(total_payroll) OVER (ORDER BY payroll_month)
        * 100, 2
    )                                           AS increase_pct
FROM (
    SELECT
        DATE_FORMAT(s.from_date, '%Y-%m')       AS payroll_month,
        DATE_FORMAT(s.from_date, '%b %Y')       AS month_label,
        ROUND(SUM(s.salary), 2)                 AS total_payroll
    FROM salaries s
    GROUP BY
        DATE_FORMAT(s.from_date, '%Y-%m'),
        DATE_FORMAT(s.from_date, '%b %Y')
) monthly
ORDER BY payroll_month;

-- ============================================================

-- PART C: Payroll cost by department, by month
--         Reveals which dept absorbed the most cost from hikes
SELECT
    DATE_FORMAT(s.from_date, '%b %Y')           AS month_label,
    DATE_FORMAT(s.from_date, '%Y-%m')           AS payroll_month,
    d.dept_name,
    ROUND(SUM(s.salary), 2)                     AS dept_payroll,
    COUNT(DISTINCT s.emp_id)                    AS headcount
FROM salaries s
JOIN employees e   ON s.emp_id  = e.emp_id
JOIN departments d ON e.dept_id = d.dept_id
GROUP BY
    DATE_FORMAT(s.from_date, '%Y-%m'),
    DATE_FORMAT(s.from_date, '%b %Y'),
    d.dept_name
ORDER BY payroll_month, dept_payroll DESC;

-- ============================================================
-- INSIGHT TO LOOK FOR:
--   PART A — Oct and Nov should be similar (same salary, Nov
--             has a duplicate row so watch for that)
--             Dec should jump ~5%, Jan should jump ~10%
--   PART B — increase_pct in Dec should be ~5%
--             increase_pct in Jan should be ~10%
--             This confirms the hike data is correct
--   PART C — Engineering likely has highest absolute increase
--             because they have the highest base salaries
--
-- NOTE ON THE DATA:
--   Nov 2025 has a duplicate insert in the database — two rows
--   per employee for Nov. When you see Nov payroll = 2x Oct,
--   that is expected from the source data. Mention this as a
--   data quality finding in your project — it shows analyst
--   attention to detail.
--
-- EXPORT AS: p1_q5_monthly_payroll.csv       (Part A)
--            p1_q5_payroll_change.csv         (Part B)
--            p1_q5_dept_payroll_monthly.csv   (Part C)
-- ============================================================











































