# Black Friday Sales Forecasting

## 📌 Project Overview
This project conducts an in-depth **inventory and sales analysis** of a retail store’s **past three years of Black Friday sales data** to accurately predict inventory needs for the upcoming year. By identifying the best-selling and least-selling products across different store locations, this analysis provides actionable insights for **stock management, sales strategy, and revenue optimization.**

## 🚀 Key Features & Impact
- **Boosting Sales Opportunities**: Ensures high-demand products remain in stock, preventing lost sales.
- **Avoiding Overstocking**: Reduces unnecessary storage costs and markdown losses.
- **Competitive Edge**: Helps retailers prepare better than competitors with data-driven insights.
- **Data-Driven Black Friday Deals**: Identifies which products to discount or promote.
- **Optimized Inventory Planning**: Streamlines warehouse and supply chain logistics.

## 📊 Data Pipeline & Analysis
### 🔹 Data Collection & Storage
- **Dataset**: Kaggle’s *Black Friday Sales Data* (5,000 transactions)
- **Database**: **MySQL** relational database with the following tables:
  - **Sales Data**: Transactional sales history
  - **Category Master**: Product categories
  - **Product Master**: Individual product details
  - **Inventory Data**: Current stock levels by location

### 🔹 Data Cleaning & Transformation
- **Data Cleaning**: Removing unnecessary columns, handling missing values.
- **SQL Queries**: Extensive **MySQL queries** used to merge, transform, and structure sales data.
- **Data Modeling**: **Joined tables** using primary and foreign keys to create a consolidated `combined_sales_data` table.

### 🔹 Exploratory Data Analysis (EDA)
- **Python Libraries Used**: `Matplotlib`, `Pandas`, `MySQL Connector`
- **SQL & Python Integration**: Queries executed in Python for efficient data extraction.
- **Generated Insights**:
  - Top-selling products & categories across different store locations.
  - Sales trends for each product over three years.
  - Forecasted product demand for the upcoming year.

### 🔹 Sales Forecasting & Stock Adjustment
- **Growth Rate Calculation**: Predicted sales trends using a **percent-change model**.
- **Projected Inventory Table**: Compared projected sales demand with current stock levels.
- **Stock Optimization Strategy**:
  - Identifies understocked products requiring **inventory increase**.
  - Highlights overstocked products for **stock reallocation** or discount strategies.
  
## 📈 Sample Visualizations
- **City-wise category rankings** (last three years)
- **Top 3 best-selling products per location**
- **Sales trends for each product over time**
- **Projected stock adjustments for optimal inventory planning**

## 🛠️ Tech Stack
- **Database**: MySQL
- **Backend**: Python (MySQL Connector, Pandas, Matplotlib)
- **Data Visualization**: Matplotlib for trend analysis & forecasting
- **Version Control**: Git & GitHub

## 📌 Future Improvements
- **Advanced Forecasting Models**: Implement machine learning techniques for better predictive accuracy.
- **Scalability**: Optimize queries for larger datasets.
- **Real-time Data Processing**: Integrate real-time sales data for dynamic inventory tracking.

## 🏆 About the Developer
👋 Hi, I’m **Vedanti Patil**, a passionate data scientist and software developer specializing in **data-driven decision-making, AI, and automation.**

🔗 **Let’s connect!** [LinkedIn](https://www.linkedin.com/in/vedanti-patil-038661186/) | [GitHub](https://github.com/VedantiPat)

---
📌 *Feel free to fork, contribute, or reach out if you have any questions!* 🚀

