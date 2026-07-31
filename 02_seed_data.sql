-- =====================================================================
-- 02_seed_data.sql
-- GigConnect Sample Data
-- =====================================================================

SET search_path TO gigconnect;

-- =====================================================
-- Companies
-- =====================================================

INSERT INTO companies (company_name, industry, city)
VALUES
('BrightPixel Studio', 'Design', 'Austin'),
('Nimbus Cloud Labs', 'Technology', 'Seattle'),
('GreenLeaf Organics', 'E-commerce', 'Denver'),
('Ledger & Co', 'Finance', 'New York'),
('PulseFit Media', 'Health & Wellness', 'Miami');

-- =====================================================
-- Freelancers
-- =====================================================

INSERT INTO freelancers
(full_name, email, city, primary_skill, experience_years, hourly_rate)
VALUES
('Rahul Sharma','rahul@gmail.com','Mumbai','Web Development',5,35.00),
('Priya Verma','priya@gmail.com','Delhi','Graphic Design',3,25.00),
('Amit Joshi','amit@gmail.com','Pune','SEO',4,30.00),
('Sneha Patil','sneha@gmail.com','Nagpur','Content Writing',2,20.00),
('Rohan Gupta','rohan@gmail.com','Bangalore','Data Analysis',6,40.00),
('Neha Singh','neha@gmail.com','Hyderabad','UI/UX Design',5,38.00),
('Karan Mehta','karan@gmail.com','Chennai','Mobile Development',4,45.00),
('Anjali Jain','anjali@gmail.com','Jaipur','Video Editing',3,28.00),
('Vikram Shah','vikram@gmail.com','Ahmedabad','Web Development',7,50.00),
('Pooja Kulkarni','pooja@gmail.com','Pune','Graphic Design',4,32.00);

-- =====================================================
-- Job Postings
-- =====================================================

INSERT INTO job_postings
(company_id,title,category,budget,posted_date,status)
VALUES
(1,'Company Website Development','Web Development',3000,'2026-07-01','OPEN'),
(2,'Modern Logo Design','Graphic Design',1000,'2026-07-05','OPEN'),
(3,'SEO Optimization Project','SEO',1500,'2026-06-15','CLOSED'),
(4,'Financial Dashboard','Data Analysis',2500,'2026-07-10','OPEN'),
(5,'Health Blog Writing','Content Writing',900,'2026-05-20','CLOSED'),
(1,'Android Application','Mobile Development',4500,'2026-07-18','OPEN'),
(2,'Corporate Video Editing','Video Editing',1800,'2026-06-28','OPEN'),
(3,'E-commerce UI Design','UI/UX Design',2200,'2026-07-12','OPEN');

-- =====================================================
-- Applications
-- =====================================================

INSERT INTO applications
(job_id,freelancer_id,applied_date,status)
VALUES
(1,1,'2026-07-02','HIRED'),
(1,2,'2026-07-03','REJECTED'),
(1,3,'2026-07-03','SHORTLISTED'),

(2,2,'2026-07-06','HIRED'),
(2,10,'2026-07-06','REJECTED'),

(3,3,'2026-06-16','HIRED'),
(3,5,'2026-06-17','REJECTED'),

(4,5,'2026-07-11','HIRED'),
(4,6,'2026-07-11','SHORTLISTED'),

(5,4,'2026-05-21','HIRED'),
(5,8,'2026-05-22','REJECTED'),

(6,7,'2026-07-19','HIRED'),
(6,9,'2026-07-20','APPLIED'),

(7,8,'2026-06-29','SHORTLISTED'),
(7,10,'2026-06-30','HIRED'),

(8,6,'2026-07-13','HIRED'),
(8,4,'2026-07-14','APPLIED');

-- =====================================================
-- Reviews
-- =====================================================

INSERT INTO reviews
(application_id,rating,review_date,comments)
VALUES
(1,5,'2026-07-15','Excellent work and delivered before deadline.'),
(4,4,'2026-07-18','Very creative logo design.'),
(6,5,'2026-06-30','Outstanding SEO performance.'),
(8,5,'2026-07-25','Highly skilled data analyst.'),
(10,4,'2026-06-05','Good content writer with quality work.'),
(12,5,'2026-07-28','Excellent mobile application.'),
(15,4,'2026-07-10','Professional video editing.'),
(16,5,'2026-07-25','Amazing UI/UX design.');

-- =====================================================
-- Verify Data
-- =====================================================

SELECT 'companies' AS table_name, COUNT(*) FROM companies
UNION ALL
SELECT 'freelancers', COUNT(*) FROM freelancers
UNION ALL
SELECT 'job_postings', COUNT(*) FROM job_postings
UNION ALL
SELECT 'applications', COUNT(*) FROM applications
UNION ALL
SELECT 'reviews', COUNT(*) FROM reviews;
