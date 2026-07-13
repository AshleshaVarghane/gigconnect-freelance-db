-- =====================================================================
-- 02_seed_data.sql
-- Populates GigConnect with realistic sample data.
-- =====================================================================

SET search_path TO gigconnect;

-- ---------------------------------------------------------------------
-- companies (12)
-- ---------------------------------------------------------------------
INSERT INTO companies (company_name, industry, city) VALUES
('BrightPixel Studio', 'Design', 'Austin'),
('Nimbus Cloud Labs', 'Technology', 'Seattle'),
('GreenLeaf Organics', 'E-commerce', 'Denver'),
('Ledger & Co', 'Finance', 'New York'),
('PulseFit Media', 'Health & Wellness', 'Miami'),
('Wanderly Travel', 'Travel', 'Chicago'),
('CodeForge Inc', 'Technology', 'San Francisco'),
('Bloom Marketing Group', 'Marketing', 'Boston'),
('Artisan Roast Co', 'Food & Beverage', 'Portland'),
('NovaTech Solutions', 'Technology', 'Austin'),
('UrbanNest Realty', 'Real Estate', 'Phoenix'),
('EduSpark Learning', 'Education', 'Denver');

-- ---------------------------------------------------------------------
-- freelancers (45 — intentionally more than the ~150 applications can
-- cover, so some freelancers naturally never apply to any job)
-- ---------------------------------------------------------------------
INSERT INTO freelancers (full_name, email, city, primary_skill, experience_years, hourly_rate)
SELECT
    'Freelancer ' || g,
    'freelancer' || g || '@example.com',
    (ARRAY['Austin','Seattle','Denver','New York','Miami','Chicago','Remote','Portland'])[(RANDOM()*7+1)::INT],
    (ARRAY['Web Development','Graphic Design','Content Writing','SEO','Video Editing','Data Analysis','Mobile Development','UI/UX Design'])[(RANDOM()*7+1)::INT],
    (RANDOM() * 10)::INT,
    ROUND((RANDOM() * 90 + 15)::NUMERIC, 2)
FROM generate_series(1, 45) AS g;

-- ---------------------------------------------------------------------
-- job_postings (40)
-- Dates are anchored to CURRENT_DATE (not a fixed calendar date) so
-- the OPEN/CLOSED split stays realistic no matter when this script
-- is run: postings from the last 30 days are OPEN, older ones CLOSED.
-- ---------------------------------------------------------------------
INSERT INTO job_postings (company_id, title, category, budget, posted_date, status)
SELECT
    (RANDOM() * 11 + 1)::INT AS company_id,
    'Project ' || g || ': ' || cat,
    cat,
    ROUND((RANDOM() * 4500 + 500)::NUMERIC, 2),
    p_date,
    CASE WHEN p_date < CURRENT_DATE - 30 THEN 'CLOSED' ELSE 'OPEN' END
FROM (
    SELECT
        g,
        (ARRAY['Web Development','Graphic Design','Content Writing','SEO','Video Editing','Data Analysis','Mobile Development','UI/UX Design'])[(RANDOM()*7+1)::INT] AS cat,
        CURRENT_DATE - (RANDOM() * 300)::INT AS p_date
    FROM generate_series(1, 40) AS g
) sub;

-- ---------------------------------------------------------------------
-- applications (150 — freelancers applying to jobs, no duplicate pairs)
-- applied_date is derived from each job's real posted_date so an
-- application can never predate the job it's applying to.
-- ---------------------------------------------------------------------
INSERT INTO applications (job_id, freelancer_id, applied_date, status)
SELECT DISTINCT ON (job_id, freelancer_id)
    job_id,
    freelancer_id,
    a_date,
    st
FROM (
    SELECT
        j.job_id,
        (RANDOM() * 44 + 1)::INT AS freelancer_id,
        j.posted_date + (RANDOM() * 25 + 1)::INT AS a_date,
        (ARRAY['APPLIED','SHORTLISTED','REJECTED','REJECTED','HIRED'])[(RANDOM()*4+1)::INT] AS st
    FROM job_postings j
    CROSS JOIN generate_series(1, 7)   -- ~7 candidate applications per job
) sub
LIMIT 150;

-- ---------------------------------------------------------------------
-- reviews (one per HIRED application, ~80% of hired contracts completed)
-- ---------------------------------------------------------------------
INSERT INTO reviews (application_id, rating, review_date, comments)
SELECT
    a.application_id,
    (RANDOM() * 4 + 1)::INT AS rating,
    a.applied_date + (RANDOM() * 30 + 10)::INT AS review_date,
    (ARRAY[
        'Great communication and delivered on time.',
        'Solid work, would hire again.',
        'Met expectations, minor delays.',
        'Exceptional quality, highly recommended.',
        'Good work but needed a few revisions.'
    ])[(RANDOM()*4+1)::INT]
FROM applications a
WHERE a.status = 'HIRED'
  AND RANDOM() < 0.8;

-- Sanity check counts
SELECT 'companies' AS table_name, COUNT(*) FROM companies
UNION ALL SELECT 'freelancers', COUNT(*) FROM freelancers
UNION ALL SELECT 'job_postings', COUNT(*) FROM job_postings
UNION ALL SELECT 'applications', COUNT(*) FROM applications
UNION ALL SELECT 'reviews', COUNT(*) FROM reviews;
