# 🎯 GigConnect
### *Where Talent Meets Opportunity — A Freelance Marketplace, Built From the Database Up*

> Every freelance platform you've ever used — Upwork, Fiverr, Toptal — runs on the same
> invisible skeleton: companies post work, freelancers chase it, some get hired, fewer
> get 5 stars. This project **is** that skeleton, built and queried entirely in
> PostgreSQL.

---

## 🕹️ The Premise

Picture the lifecycle of a single gig:

```
   🏢 Company posts a job
          │
          ▼
   📝 Freelancers apply
          │
          ▼
   🔍 Some get shortlisted, most get rejected
          │
          ▼
   🤝 One gets hired
          │
          ▼
   ⭐ A review closes the loop
```

That's not just a story — it's a **schema**. Five tables, each one a stage in that
funnel, connected by foreign keys instead of guesswork.

---

## 🗺️ The Blueprint

```
 companies                job_postings              applications              reviews
┌───────────────┐  1:N  ┌────────────────┐   1:N  ┌────────────────┐  1:1  ┌──────────────┐
│ company_id PK │──────▶│ job_id      PK │───────▶│ application_id │──────▶│ review_id PK │
│ company_name  │       │ company_id  FK │        │ job_id      FK │       │ application_ │
│ industry      │       │ title          │        │ freelancer_ FK │       │ rating (1-5) │
│ city          │       │ category       │        │ status         │       │ review_date  │
└───────────────┘       │ budget         │        └────────┬───────┘       │ comments     │
                         │ posted_date    │                 │ N:1          └──────────────┘
                         │ status         │                 ▼
                         └────────────────┘        freelancers
                                                   ┌────────────────┐
                                                   │ freelancer_ PK │
                                                   │ full_name      │
                                                   │ primary_skill  │
                                                   │ experience_yrs │
                                                   │ hourly_rate    │
                                                   └────────────────┘
```

**The `applications` table is the plot twist.** It's not just a join table — it carries
its own status (`APPLIED` → `SHORTLISTED` → `HIRED`/`REJECTED`), which means the data
itself tells a story about *who almost got the gig* and *who actually did*.

---

## 🧰 What's in the Box

| File | Role |
|---|---|
| `01_schema.sql` | Lays the foundation — 5 tables, foreign keys, `CHECK` constraints, and indexes on every join column |
| `02_seed_data.sql` | Breathes life into it — 12 companies, 45 freelancers, 40 jobs, 150 applications, ~20 reviews, all generated with SQL itself (no CSV imports) |
| `03_queries.sql` | Interrogates it — 14 questions a real marketplace ops team would actually ask |

**A quiet detail that matters:** the seed data anchors every date to `CURRENT_DATE`
rather than a hardcoded calendar date. Run this script today, run it a year from now —
the "open jobs" and "days to first application" queries will still make sense either way.

---

## ⚡ Get It Running

```bash
createdb gigconnect

psql -d gigconnect -f 01_schema.sql
psql -d gigconnect -f 02_seed_data.sql
psql -d gigconnect -f 03_queries.sql
```

Three commands, one working marketplace. Each step prints a sanity check so you know
it worked before moving to the next.

---

## 🔎 Questions This Database Can Answer

- 💼 Which jobs are open *right now*, and who posted them?
- 📊 Which skill category gets the most applications — is UI/UX hot or is everyone chasing Web Dev?
- 🏆 Which freelancers actually convert applications into hires (hire rate ≠ application count)?
- 💰 Which companies pay the most on average — and is that industry-specific?
- 👻 Which freelancers are on the platform but have never lifted a finger to apply?
- ⭐ Who are the top-rated freelancers, and do they charge more per hour because of it?
- ⏱️ On average, how long does it take a job posting to get its first bite?

Every one of these is a real `SELECT` in `03_queries.sql` — joins, `GROUP BY`/`HAVING`,
`CASE WHEN` funnel labeling, subqueries, and conditional aggregation, all working
against a schema designed to actually need them.

---

## 🚧 If This Were a Real Startup, Next I'd Ship...

- [ ] A `contracts` table to separate "hired" from "actually finished the work"
- [ ] A trigger to auto-close a job the moment it gets a `HIRED` application
- [ ] Window functions — ranking freelancers within their skill category, running
      totals of monthly job postings
- [ ] `EXPLAIN ANALYZE` benchmarks once the dataset scales past what an index doesn't matter for

---

## 🛠️ Built With
PostgreSQL · Pure SQL · Zero ORMs · Zero shortcuts

---

*Constraints enforced by the database, not just assumed by the developer — because the
worst bugs are the ones the schema should've caught in the first place.*
