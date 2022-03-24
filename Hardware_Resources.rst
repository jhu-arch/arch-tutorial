Hardware Resources

.. list-table:: Compute Nodes
   :widths: 25 25 50
   :header-rows: 1

   * - Partition
     - Nodes
     - Processors
     - Cores
     - Memory
     - Local Disk
     - GPUs
     - Job Time Limit & Node Names
   * - defq
     - 496
     - Intel(R) Xeon(R) Gold 6248R CPU @ 3.00GHz
     - 48
     - 189 GB
     - 915 GB
     - N/A
     - 3 days c[001-232,241-280,289-328,337-376,385-424,433-440,625-720]
   * - bigmem
     - 13
     - Intel(R) Xeon(R) Gold 6248R CPU @ 3.00GHz
     - 48
     - 1.47 TB
     - 816 GB
     - N/A
     - 2 days bigmem[01-13]
   * - a100
     - 10
     - Intel(R) Xeon(R) Gold 6248R CPU @ 3.00GHz
     - 48
     - 189 GB
     - 1.4 TB
     - 4*A100
     -3 days gpu[01-10]
   * - Total
     - 519
     -
     - 24,912
     -
     -
     - 40*A100
     -
