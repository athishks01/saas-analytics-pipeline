Activated Users = 
CALCULATE(
    DISTINCTCOUNT(events[user_id]),
    events[event_name] = "premium_feature_used"
)

Activation Rate = 
DIVIDE(
    [Activated Users],
    [Total Users]
)

Active Paying % = DIVIDE([Paying Users],[MAU])

Active Users in Month = 
CALCULATE(
    DISTINCTCOUNT(users[user_id]),
    subscriptions[status] = "active"
)

ARPU = 
DIVIDE(
    [Total Revenue],
    [Paying Users]
)

Avg Events per User = 
DIVIDE(
    COUNT(events[event_name]),
    DISTINCTCOUNT(events[user_id])
)

AVG LTV = 
AVERAGEX(
    VALUES(payments[user_id]),
    CALCULATE(SUM(payments[amount]))
)

CAC = 
DIVIDE(
    sum(marketing_spend[spend]),
    DISTINCTCOUNT(users[user_id])
)

Cohort Users = 
CALCULATE(
    DISTINCTCOUNT(users[user_id]),
    USERELATIONSHIP(users[signup_date], DateTable[Date])
)

DAU = 
CALCULATE(
    DISTINCTCOUNT(events[user_id])
)

LTV to CAC = 
DIVIDE(
    [AVG LTV],
    [CAC]
)

MAU = 
CALCULATE(
    DISTINCTCOUNT(events[user_id]),
    REMOVEFILTERS(DateTable[Date])
)

MRR = 
VAR LatestMonth =
    MAX(payments[YearMonth])

RETURN
CALCULATE(
    SUM(payments[amount]),
    FILTER(
        ALL(payments),
        payments[YearMonth] = LatestMonth
    )
)

New Users = 
CALCULATE(
    DISTINCTCOUNT(users[user_id]),
    USERELATIONSHIP(DateTable[Date], users[signup_date])
)

Paid Churn % = 
DIVIDE(
    CALCULATE(
        COUNTROWS(subscriptions),
        subscriptions[status] = "canceled",
        USERELATIONSHIP(DateTable[Date], users[signup_date])
    ),
    CALCULATE(
        COUNTROWS(subscriptions),
        subscriptions[status] <> "trial_churn",
        USERELATIONSHIP(DateTable[Date], users[signup_date])
    )
)


Paying Users = DISTINCTCOUNT(payments[user_id])

Retention % = 
DIVIDE(
    [Active Users in Month],
    [Cohort Users]
)

Revenue per Active User = 
DIVIDE(
    [Total Revenue],
    [MAU]
)

Stickiness = 
DIVIDE(
    AVERAGEX(
        VALUES(DateTable[Date]),
        [DAU]
    ),
    [MAU]
)

Total Revenue = SUM(payments[amount])

Total Spend = SUM(marketing_spend[spend])

Total Users = DISTINCTCOUNT(users[user_id])

Trial to Paid % = 
DIVIDE(
    CALCULATE(
        DISTINCTCOUNT(subscriptions[user_id]),
        subscriptions[status] = "active",
        USERELATIONSHIP(DateTable[Date], users[signup_date])
    ),
    CALCULATE(
        DISTINCTCOUNT(subscriptions[user_id]),
        USERELATIONSHIP(DateTable[Date], users[signup_date])
    )
)

Users by Channel = DISTINCTCOUNT(users[user_id])


Users by Status = COUNTROWS(subscriptions)