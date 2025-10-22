-- 1. Create the Database
CREATE DATABASE IF NOT EXISTS supply_chain_db;

-- 2. Select the Database
USE supply_chain_db;

-- Check for missing values
SELECT
    COUNT(*) - COUNT(Product_type) AS Missing_Product_Type,
    COUNT(*) - COUNT(Revenue_generated) AS Missing_Revenue,
    COUNT(*) - COUNT(Profit) AS Missing_Profit,
    COUNT(*) - COUNT(Inspection_results) AS Missing_Inspection_Result
FROM
    cleaned_supply_chain_data;
    
-- Check for duplicates
SELECT
    Product_type, SKU, Revenue_generated, Profit, COUNT(*) as Duplicate_Count
FROM
    cleaned_supply_chain_data
GROUP BY
    Product_type, SKU, Revenue_generated, Profit
HAVING
    COUNT(*) > 1;

-- Which product categories are the most profitable, and how do they compare in terms of total sales volume?
SELECT
    Product_type,
    SUM(Profit) AS Total_Profit,
    ROUND(AVG(Profit), 2) AS Avg_Profit_Per_Transaction,
    SUM(Number_of_products_sold) AS Total_Units_Sold
FROM
    cleaned_supply_chain_data
GROUP BY
    Product_type
ORDER BY
    Total_Profit DESC;

-- Which customer demographics segment is the most profitable, and are there any segments showing surprisingly low performance?
SELECT
    Customer_demographics,
    SUM(Profit) AS Total_Profit,
    ROUND(SUM(Profit) / SUM(Revenue_generated) * 100, 2) AS Profit_Margin_Percent,
    COUNT(SKU) AS Transaction_Count
FROM
    cleaned_supply_chain_data
GROUP BY
    Customer_demographics
ORDER BY
    Total_Profit DESC;

-- What is the financial cost and average defect rate associated with Fail inspection results compared to Pass?
SELECT
    Inspection_results,
    COUNT(*) AS Total_Records,
    ROUND(AVG(Defect_rates), 2) AS Average_Defect_Rate,
    SUM(Profit) AS Total_Profit,
    SUM(Costs) AS Total_Costs_Before_Profit
FROM
    cleaned_supply_chain_data
GROUP BY
    Inspection_results
ORDER BY
    Total_Profit DESC;
    
-- Which Supplier and Location combination is responsible for the highest average defect rates?
SELECT
    Supplier_name,
    Location,
    ROUND(AVG(Defect_rates), 2) AS Avg_Defect_Rate,
    COUNT(*) AS Total_Transactions,
    SUM(CASE WHEN Inspection_results = 'Fail' THEN 1 ELSE 0 END) AS Fail_Count
FROM
    cleaned_supply_chain_data
GROUP BY
    Supplier_name, Location
HAVING
    COUNT(*) >= 5 -- Filter to only analyze suppliers with a meaningful transaction count
ORDER BY
    Avg_Defect_Rate DESC;
    
-- How do different transportation modes compare in terms of average shipping cost and average shipping lead time?
SELECT
    Transportation_modes,
    ROUND(AVG(Shipping_costs), 2) AS Avg_Shipping_Cost,
    ROUND(AVG(Shipping_Lead_Time_days), 2) AS Avg_Lead_Time_Days,
    COUNT(*) AS Total_Shipments
FROM
    cleaned_supply_chain_data
GROUP BY
    Transportation_modes
ORDER BY
    Avg_Shipping_Cost DESC;

-- Which shipping carriers and routes are performing poorly by having the highest average Lead_Time_Delta_days (actual vs. expected delivery time)?
SELECT
    Shipping_carriers,
    Routes,
    ROUND(AVG(Lead_Time_Delta_days), 2) AS Avg_Lead_Time_Delta
FROM
    cleaned_supply_chain_data
GROUP BY
    Shipping_carriers, Routes
HAVING
    COUNT(*) >= 5
ORDER BY
    Avg_Lead_Time_Delta DESC;
