import mysql.connector
import matplotlib.pyplot as plt
import pandas as pd
import numpy as np

db_connection = mysql.connector.connect(
    host="localhost",
    user="root",
    password="pIH2$1509l",
    database="black_friday_analysis"
)


sql_query = """
SELECT
	sales_year,
    city_category,
    product_id,
    product_name,
    SUM(product_quantity) AS total_quantity,
    SUM(total_purchase_amount) AS total_amount_dollars
FROM
    combined_sales_data
GROUP BY
    sales_year,
    city_category,
    product_id,
    product_name 
ORDER BY
    sales_year ASC, city_category ASC, total_quantity DESC;
"""

product_summary = pd.read_sql_query(sql_query, con=db_connection)

sql_query2 = """
SELECT * FROM combined_sales_data;
"""

combined_sales_data = pd.read_sql_query(sql_query2, con=db_connection)

sql_query3 = """
SELECT
	sales_year,
    city_category,
    product_category1,
    category_name,
    SUM(product_quantity) AS total_quantity
FROM
    combined_sales_data
GROUP BY
    sales_year,
    city_category,
    product_category1,
    category_name 
ORDER BY
    sales_year ASC, city_category ASC, total_quantity DESC;
"""

category_summary = pd.read_sql_query(sql_query3, con=db_connection)

sql_query4 = """
WITH random_products AS (
    SELECT DISTINCT product_id, city_category
    FROM combined_sales_data
    ORDER BY RAND()
    LIMIT 5
)
SELECT
    c.sales_year,
    c.city_category,
    c.product_id,
    c.product_name,
    SUM(c.product_quantity) AS total_quantity,
    SUM(c.total_purchase_amount) AS total_amount_dollars
FROM
    combined_sales_data c
JOIN
    random_products rp
ON
    c.product_id = rp.product_id AND c.city_category = rp.city_category
GROUP BY
    c.sales_year,
    c.city_category,
    c.product_id,
    c.product_name
ORDER BY
    rp.product_id, c.sales_year;

"""

selected_products = pd.read_sql_query(sql_query4, con=db_connection)

# Close MySQL connection
db_connection.close()


# Process data to get top 3 selling products per year by city
top3_per_year_city = product_summary.groupby(['sales_year', 'city_category']).apply(lambda x: x.nlargest(3, 'total_quantity')).reset_index(drop=True)

# Create a pastel color palette
pastel_colors = ['#FFD8B1', '#FFA07A', '#FFB6C1', '#FFC0CB', '#FFD700', '#FF69B4', '#FFE4E1', '#FF6347', '#FF4500', '#FF8C00']

# Create a plot for top 3 each year by city
years = top3_per_year_city['sales_year'].unique()
for year in years:
    plt.figure(figsize=(10, 6))
    plt.title(f'Top 3 Selling Products in {year}', fontsize=18, fontweight='bold', fontname='Calibri', pad=20)
    
    colors = pastel_colors[:len(top3_per_year_city[top3_per_year_city['sales_year'] == year]['city_category'].unique())]
    
    for i, city in enumerate(top3_per_year_city[top3_per_year_city['sales_year'] == year]['city_category'].unique()):
        data = top3_per_year_city[(top3_per_year_city['sales_year'] == year) & (top3_per_year_city['city_category'] == city)]
        plt.barh(data['product_name'], data['total_quantity'], label=city, color=colors[i], edgecolor='grey', alpha=0.8)
    
    plt.xlabel('Total Quantity', fontsize=14, fontname='Calibri', labelpad=15)
    plt.ylabel('Product Name', fontsize=14, fontname='Calibri', labelpad=15)
    plt.legend(loc='upper right', fontsize=12)
    plt.grid(axis='x', linestyle='--', alpha=0.5)
    plt.gca().invert_yaxis()  # Invert y-axis to show top selling products at the top
    plt.tight_layout()
    
    # Customize background color
    plt.gca().set_facecolor('#F5F5F5')  # Light grey background
    
    plt.show()



# Create a plot showing the sales by category each year by city, ranked from highest sales to lowest
years = category_summary['sales_year'].unique()
for year in years:
    cities = category_summary[category_summary['sales_year'] == year]['city_category'].unique()
    for city in cities:
        # Filter data for the current year and city
        data = category_summary[(category_summary['sales_year'] == year) & (category_summary['city_category'] == city)]
        
        # Sort data by total_quantity descending to maintain ranking
        data.sort_values(by='total_quantity', ascending=False, inplace=True)
        
        # Plotting with rainbow color scheme
        plt.figure(figsize=(10, 8))
        plt.title(f'Product Category Rankings in {year} - {city}', fontsize=18, fontweight='bold', fontname='Calibri', pad=20)
        
        # Create a rainbow color palette
        num_categories = len(data)
        colors = plt.cm.rainbow(np.linspace(0, 1, num_categories))
        
        # Plot bars with rainbow colors
        for i, (category, color) in enumerate(zip(data['category_name'], colors)):
            plt.barh(category, data.loc[data['category_name'] == category, 'total_quantity'], color=color)
        
        plt.xlabel('Total Quantity', fontsize=14, fontname='Calibri', labelpad=15)
        plt.ylabel('Category Name', fontsize=14, fontname='Calibri', labelpad=15)
        plt.gca().invert_yaxis()  # Invert y-axis to show highest selling category at the top
        
        plt.tight_layout()
        plt.show()



# Create plots for trends of 5 random products over the years
# Calculate percent change for each product and city category
selected_products['percent_change'] = selected_products.groupby(['product_id', 'city_category'])['total_quantity'].pct_change() * 100

# Sort selected_products by sales_year
selected_products.sort_values(by=['product_id', 'city_category', 'sales_year'], inplace=True)

# Define a rainbow pastel color palette
rainbow_pastel_palette = ['#FFB3BA', '#FFDFBA', '#FFFFBA', '#BAFFC9', '#BAE1FF']

# Plot the trend and percent change for each selected product using bar plot with error bars
for i, (product_id, city_category) in enumerate(selected_products.groupby(['product_id', 'city_category']).groups.keys()):
    product_data = selected_products[(selected_products['product_id'] == product_id) & (selected_products['city_category'] == city_category)]
    
    fig, ax = plt.subplots(figsize=(12, 6))
    
    # Plot total quantity as bar graph with pastel color
    bars = ax.bar(product_data['sales_year'], product_data['total_quantity'], color=rainbow_pastel_palette[i % len(rainbow_pastel_palette)], edgecolor='grey', label='Total Quantity')
    ax.set_title(f'Trend of {product_data["product_name"].values[0]} in {city_category}', fontsize=18, fontname='Calibri')
    ax.set_xlabel('Sales Year', fontsize=14, fontname='Calibri')
    ax.set_ylabel('Total Quantity', fontsize=14, fontname='Calibri')
    ax.set_xticks(product_data['sales_year'])
    ax.set_xticklabels(product_data['sales_year'].astype(int))

    # Create a second y-axis for percent change
    ax2 = ax.twinx()
    ax2.set_ylabel('Percent Change (%)', fontsize=14, fontname='Calibri', color='red')
    
    # Plotting percent change as error bars on top of bars
    errors = np.abs(product_data['percent_change'])  # Absolute values for positive representation
    ax2.errorbar(product_data['sales_year'], product_data['total_quantity'], yerr=errors, fmt='o', color='red', label='Percent Change (%)')
    ax2.tick_params(axis='y', labelcolor='red')

    # Annotate the bars with the quantities
    for bar in bars:
        yval = bar.get_height()
        ax.text(bar.get_x() + bar.get_width()/2, yval + 0.5, int(yval), ha='center', va='bottom', color='grey', fontsize=10, fontname='Calibri')
    
    # Annotate the error bars with percent change
    for xval, yval, err in zip(product_data['sales_year'], product_data['total_quantity'], product_data['percent_change']):
        ax2.text(xval, yval + err + 1, f'{err:.1f}%', ha='center', va='bottom', color='red', fontsize=10, fontname='Calibri')
    
    # Customize grid and background
    ax.grid(axis='y', linestyle='--', alpha=0.5)
    ax.set_facecolor('#F5F5F5')
    
    fig.tight_layout()
    plt.show()