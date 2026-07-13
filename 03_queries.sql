-- =====================================================================
-- 03_queries.sql
-- Practical queries answered against the GigConnect schema.
-- Uses beginner-level SQL: SELECT, WHERE, JOIN, GROUP BY, HAVING,
-- ORDER BY, aggregate functions, CASE WHEN, LIKE, basic subqueries.
-- =====================================================================

SET search_path TO gigconnect;

-- Q1. List all open job postings with the hiring company's name
SELECT
    j.title,
    c.company_name,
    j.category,
    j.budget,
    j.posted_date
FROM job_postings j
JOIN companies c ON c.company_id = j.company_id
WHERE j.status = 'OPEN'
ORDER BY j.posted_date DESC;

-- Q2. Count how many jobs each company has posted
SELECT
    c.company_name,
    COUNT(j.job_id) AS jobs_posted
FROM companies c
JOIN job_postings j ON j.company_id = c.company_id
GROUP BY c.company_name
ORDER BY jobs_posted DESC;

-- Q3. Categories with more than 4 job postings (GROUP BY + HAVING)
SELECT
    category,
    COUNT(*) AS num_postings
FROM job_postings
GROUP BY category
HAVING COUNT(*) > 4
ORDER BY num_postings DESC;

-- Q4. Application funnel breakdown per job
SELECT
    j.title,
    COUNT(*) FILTER (WHERE a.status = 'APPLIED')     AS applied,
    COUNT(*) FILTER (WHERE a.status = 'SHORTLISTED')  AS shortlisted,
    COUNT(*) FILTER (WHERE a.status = 'REJECTED')     AS rejected,
    COUNT(*) FILTER (WHERE a.status = 'HIRED')        AS hired
FROM job_postings j
JOIN applications a ON a.job_id = j.job_id
GROUP BY j.title
ORDER BY hired DESC;

-- Q5. Freelancers who have applied to more than 5 jobs
SELECT
    f.full_name,
    f.primary_skill,
    COUNT(a.application_id) AS num_applications
FROM freelancers f
JOIN applications a ON a.freelancer_id = f.freelancer_id
GROUP BY f.full_name, f.primary_skill
HAVING COUNT(a.application_id) > 5
ORDER BY num_applications DESC;

-- Q6. Freelancers who have never applied to a single job (LEFT JOIN + IS NULL)
SELECT
    f.full_name,
    f.primary_skill,
    f.city
FROM freelancers f
LEFT JOIN applications a ON a.freelancer_id = f.freelancer_id
WHERE a.application_id IS NULL;

-- Q7. Label every application by its stage in the hiring funnel (CASE WHEN)
SELECT
    f.full_name,
    j.title,
    a.applied_date,
    CASE
        WHEN a.status = 'HIRED'       THEN 'Contract Won'
        WHEN a.status = 'SHORTLISTED' THEN 'In Review'
        WHEN a.status = 'REJECTED'    THEN 'Not Selected'
        ELSE 'Awaiting Response'
    END AS funnel_stage
FROM applications a
JOIN freelancers f ON f.freelancer_id = a.freelancer_id
JOIN job_postings j ON j.job_id = a.job_id
ORDER BY funnel_stage;

-- Q8. Top 5 highest-rated freelancers (avg rating from reviews)
SELECT
    f.full_name,
    f.primary_skill,
    ROUND(AVG(r.rating), 2) AS avg_rating,
    COUNT(r.review_id) AS num_reviews
FROM freelancers f
JOIN applications a ON a.freelancer_id = f.freelancer_id
JOIN reviews r ON r.application_id = a.application_id
GROUP BY f.full_name, f.primary_skill
ORDER BY avg_rating DESC, num_reviews DESC
LIMIT 5;

-- Q9. Companies with the highest average job budget
SELECT
    c.company_name,
    c.industry,
    ROUND(AVG(j.budget), 2) AS avg_budget,
    COUNT(j.job_id) AS num_jobs
FROM companies c
JOIN job_postings j ON j.company_id = c.company_id
GROUP BY c.company_name, c.industry
ORDER BY avg_budget DESC;

-- Q10. Freelancers whose hourly rate is above the platform average (subquery)
SELECT
    full_name,
    primary_skill,
    hourly_rate
FROM freelancers
WHERE hourly_rate > (SELECT AVG(hourly_rate) FROM freelancers)
ORDER BY hourly_rate DESC;

-- Q11. Most in-demand skill categories, ranked by number of applications received
SELECT
    j.category,
    COUNT(a.application_id) AS total_applications
FROM job_postings j
JOIN applications a ON a.job_id = j.job_id
GROUP BY j.category
ORDER BY total_applications DESC;

-- Q12. Hire rate per freelancer: hired applications / total applications
SELECT
    f.full_name,
    COUNT(a.application_id) AS total_applications,
    COUNT(*) FILTER (WHERE a.status = 'HIRED') AS hires,
    ROUND(
        COUNT(*) FILTER (WHERE a.status = 'HIRED')::NUMERIC
        / NULLIF(COUNT(a.application_id), 0) * 100,
    1) AS hire_rate_pct
FROM freelancers f
JOIN applications a ON a.freelancer_id = f.freelancer_id
GROUP BY f.full_name
HAVING COUNT(a.application_id) >= 3
ORDER BY hire_rate_pct DESC;

-- Q13. Companies based in cities starting with a given letter (LIKE)
SELECT company_name, industry, city
FROM companies
WHERE city LIKE 'A%' OR city LIKE 'D%'
ORDER BY city;

-- Q14. Average days between a job being posted and its first application
SELECT
    ROUND(AVG(a.applied_date - j.posted_date), 1) AS avg_days_to_first_application
FROM job_postings j
JOIN applications a ON a.job_id = j.job_id;
