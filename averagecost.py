import pandas as pd
import matplotlib.pyplot as plt

# Example DataFrame
fare_data = {'fare': [300, 400, 500, 600, 700, 800, 900]}
fare_df = pd.DataFrame(fare_data)

# Plot a box plot
plt.figure(figsize=(8, 6))
plt.boxplot(fare_df['fare'], vert=False, widths=0.7, patch_artist=True)
plt.title('Box Plot of Flight Fare')
plt.xlabel('Fare (USD)')
plt.show()
