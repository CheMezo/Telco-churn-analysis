use eda;

select * from telco_customer_churn_v2;

DESCRIBE telco_customer_churn_v2;

SELECT COUNT(*) AS nulltotalcharge
FROM telco_customer_churn_v2
WHERE TotalCharges IS NULL;

SELECT
COUNT(*) AS total_customer,
COUNT(DISTINCT customerID) AS unique_cust
FROM telco_customer_churn_v2;

-- 1. Berapa total customer dan berapa churn rate perusahaan?
SELECT COUNT(customerID) AS total_customer, 
SUM(CASE WHEN Churn='Yes' THEN 1 ELSE 0 END) AS customer_churn, 
ROUND(100 * SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)/COUNT(*),2) AS churn_rate
FROM telco_customer_churn_v2;

-- 2. Bagaimana karakteristik customer berdasarkan demographic profile?
-- by gender
SELECT  gender, 
COUNT(customerID) AS total_customer, 
SUM(CASE WHEN Churn='Yes' THEN 1 ELSE 0 END) AS customer_churn, 
ROUND(100 * SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)/COUNT(*),2) AS churn_rate
FROM telco_customer_churn_v2
GROUP BY 1
ORDER BY 1;

-- by senior cityzen
SELECT  SeniorCitizen_label, 
COUNT(customerID) AS total_customer, 
SUM(CASE WHEN Churn='Yes' THEN 1 ELSE 0 END) AS customer_churn, 
ROUND(100 * SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)/COUNT(*),2) AS churn_rate
FROM telco_customer_churn_v2
GROUP BY 1
ORDER BY 1;

-- by Partner
SELECT  Partner, 
COUNT(customerID) AS total_customer, 
SUM(CASE WHEN Churn='Yes' THEN 1 ELSE 0 END) AS customer_churn, 
ROUND(100 * SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)/COUNT(*),2) AS churn_rate
FROM telco_customer_churn_v2
GROUP BY 1
ORDER BY 1;

-- by Dependents
SELECT  Dependents, 
COUNT(customerID) AS total_customer, 
SUM(CASE WHEN Churn='Yes' THEN 1 ELSE 0 END) AS customer_churn, 
ROUND(100 * SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)/COUNT(*),2) AS churn_rate
FROM telco_customer_churn_v2
GROUP BY 1
ORDER BY 1;

-- 3. Apakah Senior Citizen memiliki churn rate yang lebih tinggi dibanding non-Senior Citizen?
SELECT  SeniorCitizen_label, 
COUNT(customerID) AS total_customer, 
SUM(CASE WHEN Churn='Yes' THEN 1 ELSE 0 END) AS customer_churn, 
ROUND(100 * SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)/COUNT(*),2) AS churn_rate
FROM telco_customer_churn_v2
GROUP BY 1
ORDER BY 1;

-- 4. Bagaimana churn berdasarkan tenure?
WITH tenure_group AS (
SELECT customerID, Churn,
		CASE
			WHEN tenure <= 12 THEN '0–12 months' 
            WHEN tenure <= 24 THEN '13-24 months'
            WHEN tenure <= 48 THEN '25-48 months'
            ELSE '49+ months'
		END AS group_tenure
FROM telco_customer_churn_v2
)

SELECT group_tenure, 
COUNT(customerID) AS total_customer,
SUM(CASE WHEN Churn='Yes' THEN 1 ELSE 0 END) AS customer_churn, 
ROUND(100 * SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)/COUNT(*),2) AS churn_rate
FROM tenure_group
GROUP BY 1
ORDER BY 1;

-- 5. Bagaimana churn rate berdasarkan jenis kontrak?
SELECT Contract, 
COUNT(customerID) AS total_customer,
SUM(CASE WHEN Churn='Yes' THEN 1 ELSE 0 END) AS customer_churn, 
ROUND(100 * SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)/COUNT(*),2) AS churn_rate
FROM telco_customer_churn_v2
GROUP BY Contract
ORDER BY Contract;

-- 6. Bagaimana churn berdasarkan Internet Service?
SELECT InternetService,
COUNT(customerID) AS total_customer,
SUM(CASE WHEN Churn='Yes' THEN 1 ELSE 0 END) AS customer_churn, 
ROUND(100 * SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)/COUNT(*),2) AS churn_rate
FROM telco_customer_churn_v2
GROUP BY InternetService
ORDER BY InternetService;

-- 7. Apakah penggunaan layanan tambahan berkaitan dengan churn?
SELECT TechSupport,
COUNT(customerID) AS total_customer,
SUM(CASE WHEN Churn='Yes' THEN 1 ELSE 0 END) AS customer_churn, 
ROUND(100 * SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)/COUNT(*),2) AS churn_rate
FROM telco_customer_churn_v2
GROUP BY TechSupport
ORDER BY TechSupport;

-- 8. Bagaimana churn berdasarkan payment method?
SELECT PaymentMethod, 
COUNT(customerID) AS total_customer,
SUM(CASE WHEN Churn='Yes' THEN 1 ELSE 0 END) AS customer_churn, 
ROUND(100 * SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)/COUNT(*),2) AS churn_rate
FROM telco_customer_churn_v2
GROUP BY PaymentMethod
ORDER BY PaymentMethod;

-- 9. Apakah Monthly Charges berkaitan dengan churn?
WITH charge_segments AS(
	SELECT 
    CustomerID,
	MonthlyCharges,
    NTILE(3) OVER (ORDER BY MonthlyCharges) AS charge_group
    FROM telco_customer_churn_v2
)

SELECT 
CASE 
	WHEN charge_group = 1 THEN 'Low'
	WHEN charge_group = 2 THEN 'Medium'
	WHEN charge_group = 3 THEN 'High'
END AS charge_segment,
COUNT(*) AS total_customer,
ROUND(AVG(MonthlyCharges),2) AS average_monthlycharges
FROM charge_segments
GROUP BY charge_group
ORDER BY charge_group;

-- 10. Berapa Monthly Revenue at Risk akibat churn dan segment mana yang paling perlu diprioritaskan?
SELECT
SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churned_customer,
ROUND(SUM(CASE WHEN Churn = 'Yes' THEN MonthlyCharges ELSE 0 END),2) AS monthly_revenue_at_risk,
ROUND(AVG(CASE WHEN Churn = 'Yes' THEN MonthlyCharges END),2) AS Avg_Monthly_Charge
FROM telco_customer_churn_v2;

SELECT 
Contract,
InternetService,
COUNT(customerID) AS total_customer,
SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS Churned_Customer,
ROUND(100.0 * SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) / COUNT(CustomerID),2) AS churned_customer_percentage,
ROUND(SUM(CASE WHEN Churn = 'Yes' THEN MonthlyCharges ELSE 0 END),2) AS monthly_revenue_at_risk,
ROUND(AVG(CASE WHEN Churn = 'Yes' THEN MonthlyCharges END),2) AS Avg_Monthly_Charge
FROM telco_customer_churn
GROUP BY 1, 2
ORDER BY 1,2;