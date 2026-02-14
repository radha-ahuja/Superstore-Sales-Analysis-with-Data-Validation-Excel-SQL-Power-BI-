Project Overview :- 

This project analyzes retail sales data from the Superstore dataset using Excel, SQL, and Power BI.

The focus was not only on analysis but also on data quality validation and cleaning before building dashboards.

🔹 Step 1: Data Cleaning in Excel (Power Query)

1. Cleaned raw CSV data using Power Query

2. Removed nulls and formatted date columns

3. Created Pivot Charts to explore initial insights

🔹 Step 2: Data Validation in SQL

1. Imported dataset into SQL database

2. Discovered cases where ShipDate < OrderDate

3. Created a cleaned view filtering valid records

4. Ensured business logic consistency

Example logic:

CREATE VIEW retail_clean AS
SELECT *
FROM retail_data
WHERE ShipDate >= OrderDate;

🔹 Step 3: Power BI Dashboard Development

1. Built interactive dashboard using validated data

2. Applied date validation filters

3. Created KPIs:

a. Total Sales

b. Total Profit

c. Total Orders

d. Profit Margin %age

e. Total Quantity

Ensured only logically valid shipping records are displayed

🔹 Key Business Insights

1. Identified top-performing regions

2. Analyzed monthly revenue trends

3. Evaluated impact of invalid shipping dates on reporting

4. Demonstrated importance of data validation before visualization

🔹 Tools Used

Excel (Power Query, Pivot Tables)

SQL (Data Validation & View Creation)

Power BI (Dashboard & DAX Measures)
