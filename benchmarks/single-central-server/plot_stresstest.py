import sys
import matplotlib.pyplot as plt
import pandas as pd


# Increase the default font size
plt.rcParams.update({'font.size': 22})


# Extract the data table from the memtier log file
file_names = ["result1.log", "result2.log", "result3.log"]

for file_name in file_names:
    with open(file_name) as f:
        data_set = []
        data_get = []
        for line in f:
            if line.startswith("SET"):
                data_set.append(line.strip())
            if line.startswith("GET"):
                data_get.append(line.strip())


    gets = []
    for get in data_get:
       entry = get.split()
       entry.remove("GET")
       gets.append(entry)

    gets = [list(map(float, lst)) for lst in gets]
    df_gets = pd.DataFrame(gets, columns = ['latency', 'distribution'])
    
    sets = []
    for set in data_set:
       entry = set.split()
       entry.remove("SET")
       sets.append(entry)

    sets = [list(map(float, lst)) for lst in sets]
    df_sets = pd.DataFrame(sets, columns = ['latency', 'distribution'])
    
    # First, let's extract the 'latency' and 'distribution' columns from each dataframe
    latencies_gets = df_gets['latency']
    distributions_gets = df_gets['distribution']
    latencies_sets = df_sets['latency']
    distributions_sets = df_sets['distribution']

    # Create the plot with two y-axes
    fig, ax1 = plt.subplots(figsize=(10, 8))
    ax2 = ax1.twinx()

    # Plot the first dataframe on the first y-axis
    ax1.plot(latencies_gets, distributions_gets, label='GET', color='blue', linewidth=2)

    # Plot the second dataframe on the second y-axis
    ax2.plot(latencies_sets, distributions_sets, label='SET', color='red', linewidth=2)

    # Add a legend
    fig.legend()


    # Add x-axis and y-axis labels
    ax1.set_xlabel("Latency in Milliseconds")
    ax1.set_ylabel("Percentage of Requests within Latency Range")

    file_name = file_name.split('.')[0]
    plt.savefig(file_name + ".png")
