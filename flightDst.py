
#Flight Distribution Over Time (Line Plot):

#Display the number of flights over time, which could be daily, monthly, or yearly.
import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
from datetime import datetime, timedelta

# Create a DataFrame with mock flight data
np.random.seed(42)

# Generating random data for demonstration
num_flights = 1000
airlines = ['Airline A', 'Airline B', 'Airline C']
origin_cities = ['City X', 'City Y', 'City Z']
destination_cities = ['City P', 'City Q', 'City R']

flights_df = pd.DataFrame({
    'airline': np.random.choice(airlines, num_flights),
    'origin_city': np.random.choice(origin_cities, num_flights),
    'destination_city': np.random.choice(destination_cities, num_flights),
    'departure_time': pd.to_datetime(np.datetime64('2023-01-01') + np.random.randint(0, 365, num_flights)),
    'arrival_time': pd.to_datetime(np.datetime64('2023-01-01') + np.random.randint(1, 365, num_flights)),
    'fare': np.random.randint(100, 1000, num_flights),
    'tickets_left': np.random.randint(50, 300, num_flights),
    'delay': np.random.randint(-30, 60, num_flights)
})

# Assuming flights_df has a 'departure_time' column
flights_df['departure_time'] = pd.to_datetime(flights_df['departure_time'])
flights_df.set_index('departure_time', inplace=True)

# Plot the number of flights over time
plt.figure(figsize=(12, 6))
flights_df.resample('M').size().plot(legend=False)
plt.title('Number of Flights Over Time')
plt.xlabel('Date')
plt.ylabel('Number of Flights')
plt.show()