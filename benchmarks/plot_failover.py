import matplotlib.pyplot as plt

# Increase the default font size
plt.rcParams.update({'font.size': 22})

# Read the values from the file into a list
values = []
with open('results_failover.txt', 'r') as f:
    for line in f:
        values += [int(x) for x in line.split(',')]

# Count the number of occurrences of each value
counts = [values.count(5), values.count(6), values.count(7), values.count(9)]

# Set the figure size to 10 inches by 8 inches
plt.figure(figsize=(10, 8))

# Create the plot with the bar function and specify a small linewidth
plt.bar([5, 6, 7, 9], counts, tick_label=['5', '6', '7', '8', '9'], linewidth=0.2)

# Add labels to the x-axis and y-axis
plt.xlabel("Failover Time in Seconds")
plt.ylabel("Number of Occurrence")

# Save the plot to a file
plt.savefig('plot_failover.png')
