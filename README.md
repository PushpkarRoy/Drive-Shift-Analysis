# 🏍️ DriveShift Dashboard – Bike Sales Analysis  

![Power BI](https://img.shields.io/badge/Tool-Power%20BI-yellow?style=for-the-badge&logo=powerbi)
![SQL](https://img.shields.io/badge/Database-PostgreSQL-blue?style=for-the-badge&logo=postgresql)
![Excel](https://img.shields.io/badge/Data%20Cleaning-Excel-green?style=for-the-badge&logo=microsoft-excel)
![Python](https://img.shields.io/badge/Language-Python-red?style=for-the-badge&logo=python)

---

## 📊 Project Overview  
The **DriveShift Dashboard** is a complete **Bike Sales Analysis Project** designed to track customer buying behavior, sales performance, and product trends using **SQL**, **Power BI**, and **Excel**.  

This project combines **data cleaning, transformation, and visualization** to help businesses identify key insights such as:
- Top-selling bikes and brands    
- Monthly and yearly sales trends         
- Average customer lifespan                     
- Customer segmentation by age, loyalty, and purchase frequency                 
                      
---                 
                 
## 🧱 Dataset Structure               
          
The project is built on **3 core tables**:    
 
### 1️⃣ `gold_sales` 
| Column Name | Description | 
|--------------|-------------| 
| order_number | Unique order ID |
| order_date | Date of purchase | 
| customer_key | Links to customer |
| product_key | Links to product |
| quantity | Number of bikes purchased |
| sales_amount | Total order value |

### 2️⃣ `gold_customers`
| Column Name | Description |
|--------------|-------------|
| customer_key | Unique customer ID |
| customer_id | Customer reference code |
| first_name | Customer's first name |
| last_name | Customer's last name |
| birthdate | Date of birth |
| gender | Gender of customer |
| city | City/Location |

### 3️⃣ `gold_products`
| Column Name | Description |
|--------------|-------------|
| product_key | Product ID |
| product_name | Bike name |
| category | Type (Sports, Cruiser, Commuter, etc.) |
| brand | Manufacturer |
| price | Selling price |
| cost | Base/manufacturing cost |

---

## 💭 Problem Statements  

The business wanted to understand:  
1. 📅 How are monthly and yearly sales performing?  
2. 👥 How long do customers stay active?  
3. 💰 Who are our VIP, Regular, and New customers?  
4. 🏍️ Which bikes and brands generate the highest revenue?  
5. 📈 What’s the average order value and spend per month?  
6. 🧓 Which age groups contribute the most to total sales?

---

## 🧮 SQL Analysis  

SQL was used for:
- Calculating **customer lifespan** between first and last orders  
- Finding **months since last purchase**  
- Segmenting customers (`VIP`, `Regular`, `New`)  
- Deriving **average monthly spend** and **average order value**  

**Key Query Example:**

📊 Power BI Dashboard
💻 Dashboard Overview

Below are the visuals created in Power BI to summarize insights clearly and interactively.

Visualization	Description
📆 Sales Trend	Monthly & Yearly revenue tracking
🧍‍♂️ Customer Segmentation	VIP / Regular / New customers
💰 Average Order Value	Spending pattern analysis
🏍️ Top Products	Best-performing bike models
🏙️ City-wise Sales	Sales by top-performing locations
👶 Age Group Analysis	Sales distribution by customer age
🖼️ Dashboard Preview

<img width="500" height="400" alt="image" src="https://github.com/user-attachments/assets/4606a85f-9c48-4dbb-97d3-0f537d077202" />


1️⃣ Main Dashboard View

2️⃣ Customer Insights View

3️⃣ Product & Sales View

🚀 Key Outcomes

✅ Identified VIP customers contributing 60%+ of total sales
✅ Found average customer lifespan = 14 months
✅ Sales peaked in Q2–Q3 2025 driven by sports models
✅ Age group 20–40 years generated the highest sales volume
✅ Built an interactive Power BI dashboard with drill-down and filters

🧩 Tools & Technologies
Tool	Purpose
Excel	Data Cleaning & Preparation
PostgreSQL	Querying & Analysis
Power BI	Visualization & Dashboard Design
Python (Pandas)	Data Validation & Profiling
📈 Insights Summary
Metric	Observation
Total Customers	1,500+
Total Orders	2,800+
Total Sales	₹2.8M+
Average Order Value	₹1,860
Avg. Customer Lifespan	14 Months
Top City	Pune
Most Popular Bike	Royal Enfield Classic 350
🎯 Conclusion

The DriveShift Dashboard empowers decision-makers with real-time, data-driven insights.
It helps identify profitable customer segments, top-performing bikes, and opportunities for growth.

This project blends SQL logic, data visualization, and business storytelling into a single analytics solution.

## 👨‍💻 Created By  

**Pushpkar Roy**  
📞 6260854602  
📧 [pushpkarroy880@gmail.com](mailto:pushpkarroy880@gmail.com)  

🔗 [**LinkedIn**](https://www.linkedin.com/in/pushpkar-roy)  
💻 [**GitHub**](https://github.com/PushpkarRoy)


⭐ If you liked this project, don’t forget to star the repository and share feedback!


---
