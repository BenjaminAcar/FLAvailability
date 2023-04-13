Before performing the benchmarks, it is advisable to reinitialize the cluster beforehand (including the redis cluster + sentinel). The code for this can be found in the parent folder.

Explanation of all files/folders:
- analysis.sh: This script performs the memtier benchmark. The output of the script are stored in the fles 'result1.log', 'result2.log', 'result3.log'.
- availability.sh: This script performs the benchmark to measure the the failover time. The results of the script are stored in the file results_failover.txt.
- plot_failover.py: This script visualizes the results of the file results_failover.txt. The output is 'plot_failover.png'
- plot_stresstest.py: This script visualizes the results of 'result1.log', 'result2.log', 'result3.log'. The output are the files: 'result1.png', 'result2.png', 'result3.png'

To do the benchmark, just run the respective file. Make sure to make the .sh files exectuable before running, by typing:
```
chmod +x <filename>.sh
```

If you want to do the benchmark for the single-central-server approach, make sure to clean the K8s cluster totally. The redis instance will be created by the ./analysis.sh file directly (for the other benchmarks, you have to create it in advance!).
