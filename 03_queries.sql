-- =====================================================================
-- 03_queries.sql
-- Simple SQL Queries for GigConnect
-- =====================================================================

SET search_path TO gigconnect;

-- Q1. Display all companies
SELECT * FROM companies;

-- Q2. Display all freelancers
SELECT * FROM freelancers;

-- Q3. Display all open job postings
SELECT *
FROM job_postings
WHERE status = 'OPEN';

-- Q4. Display all job postings sorted by budget
SELECT title, category, budget
FROM job_postings
ORDER BY budget DESC;

-- Q5. Display all freelancers from Pune
SELECT full_name, city, primary_skill
FROM freelancers
WHERE city = 'Pune';

-- Q6. List job title with company name (INNER JOIN)
SELECT
    j.title,
    c.company_name,
    j.budget
FROM job_postings j
INNER JOIN companies c
ON j.company_id = c.company_id;

-- Q7. Display all applications with freelancer name
SELECT
    f.full_name,
    a.job_id,
    a.status
FROM freelancers f
INNER JOIN applications a
ON f.freelancer_id = a.freelancer_id;

-- Q8. Count total jobs posted by each company
SELECT
    c.company_name,
    COUNT(j.job_id) AS total_jobs
FROM companies c
INNER JOIN job_postings j
ON c.company_id = j.company_id
GROUP BY c.company_name
ORDER BY total_jobs DESC;

-- Q9. Show job categories having more than one job
SELECT
    category,
    COUNT(*) AS total_jobs
FROM job_postings
GROUP BY category
HAVING COUNT(*) > 1;

-- Q10. Calculate average budget of all jobs
SELECT
    AVG(budget) AS average_budget
FROM job_postings;

-- Q11. Display freelancers who have not applied for any job
SELECT
    f.full_name,
    f.city
FROM freelancers f
LEFT JOIN applications a
ON f.freelancer_id = a.freelancer_id
WHERE a.application_id IS NULL;

-- Q12. Find companies located in cities starting with 'A'
SELECT
    company_name,
    city
FROM companies
WHERE city LIKE 'A%';

-- Q13. Display freelancers whose hourly rate is above the average hourly rate
SELECT
    full_name,
    hourly_rate
FROM freelancers
WHERE hourly_rate >
(
    SELECT AVG(hourly_rate)
    FROM freelancers
);

-- Q14. Display reviews with freelancer names
SELECT
    f.full_name,
    r.rating,
    r.comments
FROM reviews r
INNER JOIN applications a
ON r.application_id = a.application_id
INNER JOIN freelancers f
ON a.freelancer_id = f.freelancer_id;
