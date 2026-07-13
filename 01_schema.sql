-- =====================================================================
-- 01_schema.sql
-- GigConnect: Freelance Job Marketplace Database
-- Normalized schema for companies, freelancers, job postings,
-- applications, and post-contract reviews.
-- =====================================================================

DROP SCHEMA IF EXISTS gigconnect CASCADE;
CREATE SCHEMA gigconnect;
SET search_path TO gigconnect;

-- ---------------------------------------------------------------------
-- companies
-- ---------------------------------------------------------------------
CREATE TABLE companies (
    company_id     SERIAL PRIMARY KEY,
    company_name   VARCHAR(100) NOT NULL,
    industry       VARCHAR(50) NOT NULL,
    city           VARCHAR(50)
);

-- ---------------------------------------------------------------------
-- freelancers
-- ---------------------------------------------------------------------
CREATE TABLE freelancers (
    freelancer_id     SERIAL PRIMARY KEY,
    full_name         VARCHAR(100) NOT NULL,
    email             VARCHAR(100) UNIQUE NOT NULL,
    city              VARCHAR(50),
    primary_skill     VARCHAR(50) NOT NULL,
    experience_years  INT NOT NULL CHECK (experience_years >= 0),
    hourly_rate       NUMERIC(8,2) NOT NULL CHECK (hourly_rate > 0)
);

-- ---------------------------------------------------------------------
-- job_postings
-- ---------------------------------------------------------------------
CREATE TABLE job_postings (
    job_id        SERIAL PRIMARY KEY,
    company_id    INT NOT NULL REFERENCES companies(company_id),
    title         VARCHAR(150) NOT NULL,
    category      VARCHAR(50) NOT NULL,
    budget        NUMERIC(10,2) NOT NULL CHECK (budget > 0),
    posted_date   DATE NOT NULL,
    status        VARCHAR(20) NOT NULL DEFAULT 'OPEN'
                  CHECK (status IN ('OPEN','CLOSED'))
);

-- ---------------------------------------------------------------------
-- applications
-- One row per freelancer applying to one job.
-- ---------------------------------------------------------------------
CREATE TABLE applications (
    application_id  SERIAL PRIMARY KEY,
    job_id          INT NOT NULL REFERENCES job_postings(job_id),
    freelancer_id   INT NOT NULL REFERENCES freelancers(freelancer_id),
    applied_date    DATE NOT NULL,
    status          VARCHAR(20) NOT NULL DEFAULT 'APPLIED'
                    CHECK (status IN ('APPLIED','SHORTLISTED','REJECTED','HIRED')),
    UNIQUE (job_id, freelancer_id)   -- a freelancer can only apply once per job
);

-- ---------------------------------------------------------------------
-- reviews
-- One review per completed (HIRED) contract, left by the company for
-- the freelancer once the work is done.
-- ---------------------------------------------------------------------
CREATE TABLE reviews (
    review_id        SERIAL PRIMARY KEY,
    application_id   INT NOT NULL UNIQUE REFERENCES applications(application_id),
    rating           INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    review_date      DATE NOT NULL,
    comments         VARCHAR(255)
);

-- ---------------------------------------------------------------------
-- Indexes on foreign keys used heavily in joins/lookups
-- ---------------------------------------------------------------------
CREATE INDEX idx_job_postings_company_id     ON job_postings(company_id);
CREATE INDEX idx_applications_job_id         ON applications(job_id);
CREATE INDEX idx_applications_freelancer_id  ON applications(freelancer_id);
CREATE INDEX idx_applications_status         ON applications(status);
CREATE INDEX idx_reviews_application_id      ON reviews(application_id);
