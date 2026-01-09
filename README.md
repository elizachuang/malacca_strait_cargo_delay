# Malacca Strait Logistics Disruption Analysis  

<img width="auto" height="auto" alt="A professional horizontal banner with a sage green background. On the left, bold white text reads 'Malacca Strait Logistics Disruption Analysis,' followed by a subtitle in a smaller font: '48-Hour Closure Impact at the Singapore Approach (Malacca Strait) 2015 – 2025.' On the right side, there is an isometric graphic featuring three stylized shipping boxes in mint green and pink, arranged in a diagonal row." src="https://github.com/user-attachments/assets/b114a427-dc1c-4a6c-98de-095ad504e1bd" />

## 48-Hour Closure Impact at the Singapore Approach (Malacca Strait)
This project analyzes the **logistics and economic impact of a hypothetical 48-hour closure** at the Singapore Approach, one of the most critical chokepoints in global maritime trade.

The goal is to estimate:
- How much container cargo (TEU) would be delayed
- How that delay scales annually
- The approximate **economic loss (USD)** caused by the disruption

---

## 📊 Data Source

**Dataset:**  
Container Throughput, Monthly – Maritime and Port Authority (MPA) of Singapore  

- Source: data.gov.sg  
- Link:  
  https://data.gov.sg/datasets/d_da030f7028200d19ffcbe4a2d71af39c/view?utm_source=chatgpt.com  
- Description: Monthly container throughput handled by Singapore ports  
- Note: Latest month figures are preliminary estimates

---

## 📦 Data Unit

- `TEU` = *Twenty-foot Equivalent Unit*  
- Standard unit used to measure containerized cargo

---

## Step 1: Data Cleaning & Daily TEU Calculation (Excel)

Data was cleaned and transformed using **Excel Power Query Editor**.

### Calculations performed:
1. **Days in Month**
```powerquery
Date.Day(Date.EndOfMonth(#date(2024, [month], 1)))
```
2. **Daily TEU**
```
daily_teu = monthly_teu / days_in_month
```

This converts monthly throughput into an average daily container flow, which is required to model short-term disruptions.

## Step 2: Calculate 48-Hour Disruption Impact (SQL)

Assuming a 48-hour (2-day) closure, delayed TEU is calculated as:
```
SELECT
    mct."year",
    mct.month,
    mct.daily_teu,
    ROUND(mct.daily_teu * 2) AS delayed_teu_48h
FROM malacca_container_throughput mct
WHERE year BETWEEN 2015 AND 2025
ORDER BY year, month ASC;
```
### Output Columns:
- `daily_teu`: Average daily container flow
- `delayed_teu_48h`: Containers delayed by a 48-hour closure



## Step 3: Annual Total Delayed TEU
This step aggregates all monthly disruptions into annual delayed volume.
```
SELECT
    mct."year",
    ROUND(SUM(mct.daily_teu * 2)) AS annual_total_dealyed_teu
FROM malacca_container_throughput mct
GROUP BY mct."year"
ORDER BY annual_total_dealyed_teu DESC;
```
This represents the total TEU affected per year if one 48-hour disruption occurred in each month.

## Step 4: Economic Loss Estimation (USD)
To estimate economic impact, the following assumptions are used:
- Average cargo value: $30,000 per TEU
- Delay cost: $200 per TEU per day
- Disruption duration: 48 hours (2 days)

A Common Table Expression (CTE) is used for clarity.
```
WITH DailyImpact AS (
    SELECT
        mct."year",
        mct.month,
        mct.daily_teu,
        ROUND(mct.daily_teu * 2) AS delayed_teu_48h
    FROM malacca_container_throughput mct
    WHERE year BETWEEN 2015 AND 2025
)

SELECT
    di."year",
    ROUND(SUM(di.daily_teu * 2)) AS annual_total_dealyed_teu,
    ROUND(SUM(di.delayed_teu_48h) * 30000) AS cargo_value_at_risk_usd,
    ROUND(SUM(di.delayed_teu_48h) * 200) AS estimated_delay_loss_usd
FROM DailyImpact di
GROUP BY di."year"
ORDER BY estimated_delay_loss_usd DESC;
```
Output Metrics:
- Annual Total Delayed TEU: Containers impacted per year
- Cargo Value at Risk (USD): Total cargo value delayed
- Estimated Delay Loss (USD): Economic loss from delay only
(does not include knock-on effects like factory shutdowns or penalties)


## 🔑 Key Insights

- The Singapore Approach is a **high-impact maritime chokepoint** where even short disruptions can affect thousands of containers.
- A **48-hour closure** consistently delays **5,000–7,500 TEU per year**, depending on traffic levels.
- Delayed container volumes show a **long-term upward trend**, reflecting growing trade intensity through the Malacca Strait.
- The total **cargo value at risk** during a single 48-hour disruption can exceed **$200 million USD** in high-traffic years.
- Estimated **direct delay-related economic losses** range from **$1.0M to $1.5M USD per year** under conservative assumptions.
- These figures only capture **inventory delay costs** — real-world impacts could be significantly higher due to downstream supply chain disruptions.
- Even brief disruptions can have **outsized economic effects**, especially for time-sensitive or high-value goods.

---

## 🛠️ Tools Used

- **Excel (Power Query Editor)**  
  Used for data cleaning, date handling, and calculating daily TEU from monthly throughput.

- **SQL (PostgreSQL-style queries)**  
  Used to calculate delayed TEU, aggregate annual impacts, and estimate economic losses using CTEs.

- **data.gov.sg (MPA Singapore)**  
  Official source for monthly container throughput data.

---

*This project combines real-world maritime data with simple, transparent assumptions to translate operational disruptions into economic impact.*


## 👤 Contact
- Eliza C. Huang | Data Analyst with a background in UX research and data-driven analysis. Interested in roles within public policy, NGOs, human rights, and social impact organizations.
- Portfolio / Data Visualizations: Instagram – DataDrawers [https://www.instagram.com/datadrawers/]
- LinkedIn: [https://www.linkedin.com/in/chuyunh/]
