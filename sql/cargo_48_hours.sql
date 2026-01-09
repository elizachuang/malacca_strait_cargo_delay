--- Step 1 Cleaned, calcualte daily_teu in Excel Power Query Editor. Formula used for days_in_month: Date.Day(Date.EndOfMonth(#date(2024, [month], 1))) formula used in daily_teu: [monthly_teu] / [days_in_month]
--- Step 2 import data, and calculate 48 Hour disruption impact
SELECT mct."year",
mct.month,
mct.daily_teu,
ROUND(mct.daily_teu *2) AS delayed_teu_48h
FROM malacca_container_throughput mct
WHERE  year BETWEEN  2015 AND 2025
ORDER BY  year, month ASC;

---Step 3 calcualte annual total delayed teu 
SELECT mct."year",
ROUND(SUM(mct.daily_teu * 2)) as annual_total_dealyed_teu
FROM malacca_container_throughput mct
GROUP BY  mct."year"
ORDER BY annual_total_dealyed_teu DESC;

---Step 4 Calculate Economic Loss. How much USD losses during this 48 hours?
--- I will use a Common Table Expression (CTE) to keep the script clean. 
--- I assume an average cargo value of $30,000 per TEU to show the total value "at risk" during those 48 hours.
--- I assume the daily delay cost is $200 per TEU per day

WITH DailyImpact AS (
SELECT mct."year",
mct.month,
mct.daily_teu,
ROUND(mct.daily_teu *2) AS delayed_teu_48h
FROM malacca_container_throughput mct
WHERE year BETWEEN  2015 AND  2025
)

SELECT di."year",
ROUND(SUM(di.daily_teu * 2)) AS annual_total_dealyed_teu,
ROUND(SUM(di.delayed_teu_48h)*30000) AS cargo_value_at_risk_usd,
ROUND(SUM(di.delayed_teu_48h) * 200) AS estimated_delay_loss_usd
FROM DailyImpact di
GROUP BY di."year"
ORDER BY estimated_delay_loss_usd DESC;

