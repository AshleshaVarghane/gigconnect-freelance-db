# GigConnect — Freelance Job Marketplace Database

A normalized PostgreSQL database modeling a freelance marketplace
(think Upwork/Fiverr-style): companies post jobs, freelancers apply,
and completed contracts get rated. Built to demonstrate core SQL
fundamentals — joins, aggregates, `GROUP BY`/`HAVING`, `CASE WHEN`,
subqueries — against a schema with real business logic, not just flat
tables.

## Why this project

A marketplace has a natural funnel (posting → application → hire →
review), which means the queries aren't just "count rows" — they
answer real product questions: which jobs get the most interest,
which freelancers convert applications into hires, which companies
pay the most. That funnel structure is what makes this more
interesting than a single-table CRUD demo.

## Schema

```
companies ──1:N── job_postings ──1:N── applications ──1:1── reviews
                                            │
                                            N:1
                                            │
                                       freelancers
```

- **companies** — company_id, company_name, industry, city
- **freelancers** — freelancer_id, full_name, email, city, primary_skill, experience_years, hourly_rate
- **job_postings** — job_id, company_id (FK), title, category, budget, posted_date, status (OPEN/CLOSED)
- **applications** — application_id, job_id (FK), freelancer_id (FK), applied_date, status (APPLIED/SHORTLISTED/REJECTED/HIRED)
- **reviews** — review_id, application_id (FK, unique), rating (1-5), review_date, comments

Constraints worth noting:
- `applications` has a `UNIQUE (job_id, freelancer_id)` constraint — a freelancer can't apply to the same job twice
- `reviews.application_id` is `UNIQUE` — one review per completed contract
- `job_postings.status` and `applications.status` are both `CHECK`-constrained to a fixed set of valid values
- Every foreign key column has an index, since that's what every query here joins on

## File structure

```
sql/
├── 01_schema.sql      -- tables, constraints, indexes
├── 02_seed_data.sql   -- 12 companies, 45 freelancers, 40 jobs, 150 applications, ~16 reviews
└── 03_queries.sql     -- 14 queries answering real marketplace questions
```

**Note on dates:** the seed data anchors `posted_date` and `applied_date`
to `CURRENT_DATE` rather than a fixed calendar date, so the OPEN/CLOSED
job split and the "days to first application" query stay realistic no
matter when you run this script.

## How to run it

Requires PostgreSQL (tested on Postgres 16).

```bash
createdb gigconnect

psql -d gigconnect -f sql/01_schema.sql
psql -d gigconnect -f sql/02_seed_data.sql
psql -d gigconnect -f sql/03_queries.sql
```

Each seed script ends with a row-count check so you can confirm the
load worked before running the queries.

## What the queries cover

1. All open job postings with company name (JOIN)
2. Job postings per company (JOIN + GROUP BY)
3. Categories with more than 4 postings (GROUP BY + HAVING)
4. Full application funnel breakdown per job (conditional aggregation)
5. Freelancers who've applied to more than 5 jobs (GROUP BY + HAVING)
6. Freelancers who have never applied to a job (LEFT JOIN + IS NULL)
7. Every application labeled by funnel stage (CASE WHEN)
8. Top 5 highest-rated freelancers (JOIN across 3 tables + AVG)
9. Companies with the highest average job budget
10. Freelancers earning above the platform-average hourly rate (subquery)
11. Most in-demand skill categories by application volume
12. Hire rate per freelancer: hires ÷ total applications
13. Companies filtered by city name pattern (LIKE)
14. Average days between a job posting and its first application

## What I'd add next

- A `contracts` table to separate "hired" from "contract completed,"
  since right now a review is the only signal a contract finished
- A trigger to auto-close a job posting once it reaches HIRED status
- Window functions once I've learned them — e.g. ranking freelancers
  within their skill category by hire rate, or a running count of
  new job postings per month

## Tech
PostgreSQL 16 · pure SQL, no ORM
