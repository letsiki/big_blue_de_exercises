import streamlit as st
import pandas as pd
import matplotlib.pyplot as plt

def load_data():
    # Load the dataset (ensure the path matches where you've saved your dataset)
    data = pd.read_csv('transactions_2023.csv')
    data['Date'] = pd.to_datetime(data['Date'])  # Convert Date column to datetime
    return data

def plot_monthly_revenue(data, category):
    if category != 'All':
        data = data[data['Category'] == category]
    
    data['Month'] = data['Date'].dt.to_period('M')
    monthly_revenue = data.groupby('Month')['Amount'].sum()

    plt.figure(figsize=(10, 5))
    plt.plot(monthly_revenue.index.astype(str), monthly_revenue.values, marker='o', linestyle='-', color='b')
    plt.title(f'Monthly Revenue for 2023 - {category}', fontsize=16)
    plt.xlabel('Month', fontsize=12)
    plt.ylabel('Revenue ($)', fontsize=12)
    plt.xticks(rotation=45)
    plt.grid(True, which='both', linestyle='--', linewidth=0.5)
    plt.tight_layout()
    st.pyplot(plt)

def main():
    st.title('Monthly Revenue Dashboard for 2023')

    data = load_data()

    categories = ['All'] + sorted(data['Category'].unique().tolist())
    category = st.selectbox('Select a Category:', categories)

    plot_monthly_revenue(data, category)

if __name__ == '__main__':
    main()
