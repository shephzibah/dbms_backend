import pandas as pd
import matplotlib.pyplot as plt

# Example DataFrame
flights_data = {'origin': ['New York', 'Los Angeles', 'Chicago', 'New York', 'Los Angeles'],
                'destination': ['Los Angeles', 'Chicago', 'New York', 'Los Angeles', 'Chicago']}
flights_df = pd.DataFrame(flights_data)

# Count the frequency of each place
visited_counts = flights_df['origin'].append(flights_df['destination']).value_counts()

# Plot a bar chart
plt.figure(figsize=(10, 6))
visited_counts.plot(kind='bar', color='skyblue')
plt.title('Most Often Visited Places')
plt.xlabel('City')
plt.ylabel('Visit Frequency')
plt.show()
