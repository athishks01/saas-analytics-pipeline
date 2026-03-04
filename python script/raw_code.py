#!/usr/bin/env python
# coding: utf-8

import pandas as pd
import numpy as np
from datetime import datetime
import random
from sqlalchemy import create_engine

np.random.seed(42)
random.seed(42)

# Load dataset
df = pd.read_csv("Telco.csv")

# Convert TotalCharges to numeric
df['TotalCharges'] = pd.to_numeric(df['TotalCharges'], errors='coerce')

# Replace missing with 0 (new customers with tenure 0)
df['TotalCharges'] = df['TotalCharges'].fillna(0)

# Define reference date
reference_date = pd.to_datetime("2024-12-31")

# Ensure tenure is integer
df['tenure'] = df['tenure'].astype(int)

# Create signup_date
df['signup_date'] = reference_date - pd.to_timedelta(df['tenure'] * 30, unit='D')

# Trial window
df['trial_start'] = df['signup_date']
df['trial_end'] = df['signup_date'] + pd.to_timedelta(14, unit='D')

# Subscription start
df['subscription_start'] = df['trial_end']

users_df = df[['customerID', 'signup_date', 'Contract', 'MonthlyCharges']].copy()

users_df.columns = [
    'user_id',
    'signup_date',
    'plan_type',
    'monthly_fee'
]

channels = ['Organic', 'Google Ads', 'Instagram Ads', 'Referral', 'Direct']
probabilities = [0.35, 0.25, 0.15, 0.15, 0.10]

users_df['acquisition_channel'] = np.random.choice(
    channels,
    size=len(users_df),
    p=probabilities
)

df['acquisition_channel'] = users_df['acquisition_channel']

def conversion_probability(channel):
    base = 0.75

    if channel == 'Organic':
        base += 0.05
    elif channel == 'Referral':
        base += 0.07
    elif channel == 'Instagram Ads':
        base -= 0.05
    elif channel == 'Google Ads':
        base -= 0.03

    return base

df['converted'] = df['acquisition_channel'].apply(
    lambda x: np.random.rand() < conversion_probability(x)
)

df.loc[df['converted'] == False, 'tenure'] = 0

def realistic_cancel(row):
    if row['Churn'] == 'Yes' and row['tenure'] > 0:
        extra_days = np.random.randint(5, 25)
        return row['signup_date'] + pd.to_timedelta(row['tenure'] * 30 + extra_days, unit='D')
    return pd.NaT

df['cancel_date'] = df.apply(realistic_cancel, axis=1)

def rebuild_status(row):
    if not row['converted']:
        return 'trial_churn'
    elif row['Churn'] == 'Yes':
        return 'canceled'
    else:
        return 'active'

df['status'] = df.apply(rebuild_status, axis=1)

subscriptions_df = df[['customerID',
                       'trial_start',
                       'trial_end',
                       'subscription_start',
                       'cancel_date',
                       'status']].copy()

subscriptions_df.columns = [
    'user_id',
    'trial_start',
    'trial_end',
    'start_date',
    'cancel_date',
    'status'
]

payments_list = []

for _, row in df.iterrows():

    if row['status'] == 'trial_churn':
        continue

    tenure = int(row['tenure'])

    for month in range(tenure):
        payment_date = row['trial_end'] + pd.to_timedelta(month * 30, unit='D')

        if pd.notna(row['cancel_date']) and payment_date > row['cancel_date']:
            break

        payments_list.append({
            'user_id': row['customerID'],
            'amount': row['MonthlyCharges'],
            'payment_date': payment_date,
            'status': 'success'
        })

payments_df = pd.DataFrame(payments_list)

events_list = []

event_types = ['login', 'template_created', 'document_shared', 'premium_feature_used']

for _, row in df.iterrows():

    if row['status'] == 'trial_churn':
        continue

    tenure = int(row['tenure'])

    for month in range(tenure):

        if month == 0:
            active_prob = 1.0
        elif month == 1:
            active_prob = 0.85
        elif month == 2:
            active_prob = 0.75
        elif month == 3:
            active_prob = 0.65
        else:
            active_prob = 0.55

        if np.random.rand() > active_prob:
            continue

        if row['status'] == 'active':
            events_count = np.random.randint(6, 12)
        else:
            events_count = np.random.randint(2, 6)

        for _ in range(events_count):
            event_time = row['signup_date'] + pd.to_timedelta(
                month * 30 + np.random.randint(0, 28),
                unit='D'
            )

            if pd.notna(row['cancel_date']) and event_time > row['cancel_date']:
                continue

            event_name = np.random.choice(
                event_types,
                p=[0.45, 0.25, 0.2, 0.1]
            )

            events_list.append({
                'user_id': row['customerID'],
                'event_name': event_name,
                'event_time': event_time
            })

events_df = pd.DataFrame(events_list)

trial_users = subscriptions_df[
    subscriptions_df["status"] == "trial_churn"
]["user_id"].tolist()

trial_events = []

for user in trial_users:
    num_events = random.randint(3, 15)

    for _ in range(num_events):
        trial_events.append({
            "user_id": user,
            "event_name": random.choice(["login", "view_page", "trial_start"]),
            "event_time": np.random.choice(events_df["event_time"])
        })

trial_events_df = pd.DataFrame(trial_events)

events_df = pd.concat([events_df, trial_events_df], ignore_index=True)

months = pd.date_range(start="2021-01-01", end="2024-12-01", freq='MS')

marketing_data = []

channel_base_spend = {
    'Organic': 2000,
    'Google Ads': 10000,
    'Instagram Ads': 7000,
    'Referral': 3000,
    'Direct': 1000
}

for month in months:
    for channel in channels:
        spend = channel_base_spend[channel] + np.random.randint(-500, 1500)
        marketing_data.append({
            'channel': channel,
            'month': month,
            'spend': max(spend, 0)
        })

marketing_spend_df = pd.DataFrame(marketing_data)

engine = create_engine("mysql+pymysql://root:YOUR_PASSWORD@localhost/saas_clean")

users_df.to_sql(name='users', con=engine, if_exists='replace', index=False)
subscriptions_df.to_sql(name='subscriptions', con=engine, if_exists='replace', index=False)
marketing_spend_df.to_sql(name='marketing_spend', con=engine, if_exists='replace', index=False)
payments_df.to_sql(name='payments', con=engine, if_exists='replace', index=False)

chunk_size = 50000

events_df.iloc[0:chunk_size].to_sql(
    name='events',
    con=engine,
    if_exists='replace',
    index=False
)

for i in range(chunk_size, len(events_df), chunk_size):
    events_df.iloc[i:i+chunk_size].to_sql(
        name='events',
        con=engine,
        if_exists='append',
        index=False
    )
    print(f"Inserted rows {i} to {i+chunk_size}")

print(subscriptions_df.columns)