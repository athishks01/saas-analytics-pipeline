--Monthly New Users
SELECT 
    DATE_FORMAT(signup_date, '%Y-%m') AS month,
    COUNT(*) AS new_users
FROM users
GROUP BY month
ORDER BY month;


--DAU
SELECT 
    DATE(event_time) AS day,
    COUNT(DISTINCT user_id) AS dau
FROM events
GROUP BY day
ORDER BY day;


--MAU
SELECT 
    DATE_FORMAT(event_time, '%Y-%m') AS month,
    COUNT(DISTINCT user_id) AS mau
FROM events
GROUP BY month
ORDER BY month;


--Stickiness
WITH daily AS (
    SELECT 
        DATE(event_time) AS day,
        COUNT(DISTINCT user_id) AS dau
    FROM events
    GROUP BY day
),
monthly AS (
    SELECT 
        DATE_FORMAT(event_time, '%Y-%m') AS month,
        COUNT(DISTINCT user_id) AS mau
    FROM events
    GROUP BY month
)
SELECT 
    m.month,
    AVG(d.dau) AS avg_dau,
    m.mau,
    ROUND(AVG(d.dau)/m.mau, 3) AS stickiness_ratio
FROM monthly m
JOIN daily d 
    ON DATE_FORMAT(d.day, '%Y-%m') = m.month
GROUP BY m.month, m.mau
ORDER BY m.month;


--Trial → Paid Conversion
SELECT 
    ROUND(
        COUNT(CASE WHEN status != 'trial_churn' THEN 1 END) 
        / COUNT(*),
    3) AS trial_to_paid_conversion
FROM subscriptions;


--Paid Churn
SELECT 
    ROUND(
        COUNT(CASE WHEN status = 'canceled' THEN 1 END)
        /
        COUNT(CASE WHEN status != 'trial_churn' THEN 1 END),
    3) AS paid_churn_rate
FROM subscriptions;


--Activation Rate
SELECT 
    ROUND(
        COUNT(DISTINCT user_id)
        /
        (SELECT COUNT(*) FROM users),
    3) AS activation_rate
FROM events
WHERE event_name = 'premium_feature_used';


--Cohort Retention
WITH user_cohorts AS (
    SELECT 
        user_id,
        DATE_FORMAT(signup_date, '%Y-%m-01') AS cohort_month
    FROM users
),
active_months AS (
    SELECT DISTINCT 
        user_id,
        DATE_FORMAT(event_time, '%Y-%m-01') AS activity_month
    FROM events
)
SELECT 
    c.cohort_month,
    TIMESTAMPDIFF(MONTH, c.cohort_month, a.activity_month) AS month_number,
    COUNT(DISTINCT a.user_id) AS active_users
FROM user_cohorts c
JOIN active_months a ON c.user_id = a.user_id
GROUP BY 1, 2
ORDER BY 1, 2;


--Retention by Channel
WITH month3_active AS (
    SELECT DISTINCT 
        u.user_id,
        u.acquisition_channel
    FROM users u
    JOIN events e 
        ON u.user_id = e.user_id
    WHERE TIMESTAMPDIFF(
        MONTH,
        u.signup_date,
        e.event_time
    ) = 3
)
SELECT 
    u.acquisition_channel,
    ROUND(
        COUNT(DISTINCT m.user_id)
        /
        COUNT(DISTINCT u.user_id),
    3) AS month3_retention
FROM users u
LEFT JOIN month3_active m
    ON u.user_id = m.user_id
GROUP BY u.acquisition_channel;


--Engagement vs Status
WITH user_events AS (
    SELECT 
        user_id,
        COUNT(*) AS total_events
    FROM events
    GROUP BY user_id
)
SELECT 
    s.status,
    ROUND(AVG(u.total_events), 2) AS avg_total_events
FROM subscriptions s
JOIN user_events u
    ON s.user_id = u.user_id
GROUP BY s.status;


--Activation vs Churn
WITH activated AS (
    SELECT DISTINCT user_id
    FROM events
    WHERE event_name = 'premium_feature_used'
)
SELECT 
    CASE 
        WHEN a.user_id IS NOT NULL THEN 'activated'
        ELSE 'not_activated'
    END AS activation_status,
    ROUND(
        COUNT(CASE WHEN s.status = 'canceled' THEN 1 END)
        /
        COUNT(CASE WHEN s.status != 'trial_churn' THEN 1 END),
    3) AS paid_churn_rate
FROM subscriptions s
LEFT JOIN activated a 
    ON s.user_id = a.user_id
GROUP BY activation_status;


--MRR
SELECT 
    DATE_FORMAT(payment_date, '%Y-%m') AS month,
    SUM(amount) AS mrr
FROM payments
GROUP BY month
ORDER BY month;


--Active Paying Users
SELECT 
    DATE_FORMAT(payment_date, '%Y-%m') AS month,
    COUNT(DISTINCT user_id) AS paying_users
FROM payments
GROUP BY month
ORDER BY month;


--ARPU
SELECT 
    ROUND(SUM(amount) / COUNT(DISTINCT user_id), 2) AS arpu
FROM payments;


--LTV
SELECT 
    ROUND(AVG(user_revenue), 2) AS avg_ltv
FROM (
    SELECT 
        user_id,
        SUM(amount) AS user_revenue
    FROM payments
    GROUP BY user_id
) t;


--Revenue by Channel
SELECT 
    u.acquisition_channel,
    ROUND(SUM(p.amount), 2) AS total_revenue
FROM users u
JOIN payments p 
    ON u.user_id = p.user_id
GROUP BY u.acquisition_channel
ORDER BY total_revenue DESC;


-- Revenue by Status
WITH user_revenue AS (
    SELECT 
        user_id,
        SUM(amount) AS total_revenue
    FROM payments
    GROUP BY user_id
)
SELECT 
    s.status,
    ROUND(AVG(r.total_revenue), 2) AS avg_revenue
FROM subscriptions s
JOIN user_revenue r
    ON s.user_id = r.user_id
GROUP BY s.status;


-- – CAC
WITH spend AS (
    SELECT 
        channel,
        SUM(spend) AS total_spend
    FROM marketing_spend
    GROUP BY channel
),
users_acquired AS (
    SELECT 
        acquisition_channel,
        COUNT(*) AS total_users
    FROM users
    GROUP BY acquisition_channel
)
SELECT 
    s.channel,
    ROUND(s.total_spend / u.total_users, 2) AS cac
FROM spend s
JOIN users_acquired u
    ON s.channel = u.acquisition_channel;


-- LTV/CAC
WITH ltv AS (
    SELECT 
        u.acquisition_channel,
        AVG(p.user_revenue) AS avg_ltv
    FROM users u
    JOIN (
        SELECT user_id, SUM(amount) AS user_revenue
        FROM payments
        GROUP BY user_id
    ) p ON u.user_id = p.user_id
    GROUP BY u.acquisition_channel
),
spend AS (
    SELECT 
        channel,
        SUM(spend) AS total_spend
    FROM marketing_spend
    GROUP BY channel
),
users_acquired AS (
    SELECT 
        acquisition_channel,
        COUNT(*) AS total_users
    FROM users
    GROUP BY acquisition_channel
),
cac AS (
    SELECT 
        s.channel,
        s.total_spend / u.total_users AS cac
    FROM spend s
    JOIN users_acquired u
        ON s.channel = u.acquisition_channel
)
SELECT 
    l.acquisition_channel,
    ROUND(l.avg_ltv,2) AS avg_ltv,
    ROUND(c.cac,2) AS cac,
    ROUND(l.avg_ltv / c.cac,2) AS ltv_cac_ratio
FROM ltv l
JOIN cac c 
    ON l.acquisition_channel = c.channel;


-- Churn by Channel
SELECT 
    u.acquisition_channel,
    ROUND(
        COUNT(CASE WHEN s.status = 'canceled' THEN 1 END)
        /
        COUNT(CASE WHEN s.status != 'trial_churn' THEN 1 END),
    3) AS paid_churn_rate
FROM subscriptions s
JOIN users u 
    ON s.user_id = u.user_id
GROUP BY u.acquisition_channel
ORDER BY paid_churn_rate DESC;


-- Churn by Plan
SELECT 
    u.plan_type,
    ROUND(
        COUNT(CASE WHEN s.status = 'canceled' THEN 1 END)
        /
        COUNT(CASE WHEN s.status != 'trial_churn' THEN 1 END),
    3) AS paid_churn_rate
FROM subscriptions s
JOIN users u 
    ON s.user_id = u.user_id
GROUP BY u.plan_type;