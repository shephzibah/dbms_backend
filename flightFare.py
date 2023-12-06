import pandas as pd
import matplotlib.pyplot as plt
import numpy as np

# Create a DataFrame with mock fare data
np.random.seed(42)

# Generating random data for demonstration
num_flights = 1000
fare_classes = ['Economy', 'Business', 'First Class']

fare_df = pd.DataFrame({
    'flight_id': np.arange(1, num_flights + 1),
    'fare_class': np.random.choice(fare_classes, num_flights),
    'base_fare': np.random.randint(100, 800, num_flights),
    'baggage_fee': np.random.randint(20, 100, num_flights),
    'meal_fee': np.random.randint(10, 50, num_flights),
    'total_fare': 0  # Placeholder for total fare, will be calculated later
})

# Calculate total fare based on base fare, baggage fee, and meal fee
fare_df['total_fare'] = fare_df['base_fare'] + fare_df['baggage_fee'] + fare_df['meal_fee']

# Assuming fare_df has a 'total_fare' column
plt.figure(figsize=(10, 6))
plt.hist(fare_df['total_fare'], bins=20, color='skyblue', edgecolor='black')
plt.title('Flight Fare Distribution')
plt.xlabel('Total Fare (USD)')
plt.ylabel('Frequency')
plt.show()
