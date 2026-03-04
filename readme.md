# SaaS Analytics Data Pipeline
## Project Snapshot

| Component     | Description                                          |
| ------------- | ---------------------------------------------------- |
| Data Source   | Telco Customer Churn dataset                         |
| Pipeline      | Python ETL pipeline generating SaaS lifecycle data   |
| Database      | MySQL database storing subscription analytics tables |
| Orchestration | Apache Airflow DAG for automated pipeline execution  |
| Visualization | Power BI dashboard for SaaS business metrics         |
| Deployment    | Dockerized Airflow environment                       |
| Metrics       | MRR, Churn Rate, Trial Conversion, LTV, CAC, LTV/CAC |

---

## Live Dashboard

 **https://app.powerbi.com/view?r=eyJrIjoiMzk4NDJjZmEtNTk0Mi00Yzk0LTk2ZmItOTQ3NDU1YmY0ODU0IiwidCI6IjUwZTFjNGMzLTE2ZmQtNGRkZS04ODAxLWIyZDQ5NGZkN2E5ZiJ9**


This project builds an end-to-end analytics pipeline that simulates a SaaS business lifecycle and delivers key product and revenue metrics through an automated workflow.

The pipeline generates realistic subscription lifecycle data from the Telco churn dataset, loads the transformed data into a MySQL database using a Python ETL pipeline, orchestrates execution using Apache Airflow, and visualizes key SaaS metrics in a Power BI dashboard.

---

# Live Dashboard

You can view the interactive Power BI dashboard here:

🔗 **https://app.powerbi.com/view?r=eyJrIjoiMzk4NDJjZmEtNTk0Mi00Yzk0LTk2ZmItOTQ3NDU1YmY0ODU0IiwidCI6IjUwZTFjNGMzLTE2ZmQtNGRkZS04ODAxLWIyZDQ5NGZkN2E5ZiJ9**

---

# Dashboard Overview

The Power BI dashboard presents a high-level overview of SaaS performance including acquisition performance, subscription revenue trends, and churn analysis.

Key metrics included in the dashboard:

• Monthly Recurring Revenue (MRR)
• Trial to Paid Conversion Rate
• Paid Churn Rate
• Customer Lifetime Value (LTV)
• Customer Acquisition Cost (CAC)
• LTV to CAC Ratio
• Revenue by Acquisition Channel
• Cohort Retention Trends

---

# Project Architecture

```
Telco Dataset
      ↓
Python ETL (pandas / numpy)
      ↓
MySQL Database (saas_clean)
      ↓
Apache Airflow DAG
      ↓
Power BI Dashboard
```

The pipeline generates SaaS lifecycle events and loads them into MySQL tables which are then used by the Power BI dashboard to analyze business performance.

---

# Data Pipeline Components

## Data Source

The pipeline uses the **Telco Customer Churn dataset** as the base dataset to simulate a SaaS subscription lifecycle.

Additional fields and behaviors such as acquisition channel, subscription lifecycle, and event activity are generated using Python.

---

## Python ETL Pipeline

The ETL script performs the following transformations:

• Converts Telco churn dataset into SaaS-style subscription lifecycle data
• Generates signup dates based on customer tenure
• Simulates trial periods and trial conversion behavior
• Generates realistic churn and cancellation behavior
• Creates subscription payment history for each user
• Generates user product interaction events
• Simulates marketing spend across acquisition channels

The final transformed datasets are loaded into MySQL.

---

## Database Layer (MySQL)

The ETL pipeline loads data into the following tables:

• users
• subscriptions
• payments
• events
• marketing_spend

These tables simulate a simplified SaaS data warehouse schema used for analytics.

---

## Workflow Orchestration (Apache Airflow)

Apache Airflow is used to schedule and orchestrate the ETL pipeline.

The Airflow DAG automates the following workflow:

1. Trigger Python ETL pipeline
2. Generate SaaS lifecycle dataset
3. Load data into MySQL tables
4. Make updated data available for reporting

Airflow enables repeatable and automated pipeline execution.

---

## Analytics Layer (Power BI)

Power BI connects to the MySQL database to visualize business performance metrics.

The dashboard enables analysis of:

• subscription revenue growth
• customer retention behavior
• acquisition channel performance
• user engagement events
• marketing efficiency

---

# Technologies Used

Python
Pandas
NumPy
MySQL
Apache Airflow
Docker
SQL
Power BI

---

# Repository Structure

```
saas-analytics-pipeline
│
├── dags
│   └── saas_pipeline_dag.py
│
├── scripts
│   └── saas_pipeline_final_code.py
│
├── sql
│   ├── schema.sql
│   └── analytics_queries.sql
│
├── data
│   └── Telco.csv
│
├── powerbi
│   └── saas_dashboard.pbix
│
├── docker-compose.yml
├── requirements.txt
├── README.md
└── .gitignore
```

---

# How to Run the Pipeline

Start the Airflow environment using Docker.

```
docker compose up -d
```

Once containers are running, open the Airflow UI:

```
http://localhost:8080
```

Login credentials:

```
username: admin
password: admin
```

Trigger the DAG:

```
saas_mysql_pipeline
```

The ETL pipeline will run and update the MySQL tables.

---

# Example SaaS Business Metrics Generated

The pipeline enables analysis of core SaaS metrics including:

• Monthly Recurring Revenue (MRR)
• Customer Lifetime Value (LTV)
• Customer Acquisition Cost (CAC)
• LTV to CAC Ratio
• Trial Conversion Rate
• Paid Customer Churn Rate
• Cohort Retention Trends

---

# Future Improvements

Possible enhancements to this project include:

• incremental data loading instead of full table replacement
• automated Power BI refresh using Power BI API
• additional data quality validation checks in Airflow
• warehouse modeling using star schema design
• deployment on cloud infrastructure

---

# Author

Athish KS

This project demonstrates an end-to-end analytics pipeline covering ETL development, workflow orchestration, database modeling, and business intelligence reporting.
