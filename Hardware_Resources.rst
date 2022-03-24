Hardware Resources





+-----------+--------+--------------------------+--------+---------+------------+---------+------------------+
| Partition |  Nodes |  Processors              | Cores  | Memory  | Local Disk |  GPUs   |  Job Time Limit  |
|           |        |                          |        |         |            |         |  & Node Names    |
+===========+========+==========================+========+=========+============+=========+==================+
| defq      |   496  | Intel(R) Xeon(R)         |   48   | 189 GB  |   915 GB   |  N/A    |3 days            |
|           |        | Gold 6248R CPU @ 3.00GHz |        |         |            |         |c[001-232,241-280,|
|           |        |                          |        |         |            |         |289-328,337-376,  |
|           |        |                          |        |         |            |         |385-424,433-440,  |
|           |        |                          |        |         |            |         |625-720]          |
+-----------+--------+--------------------------+--------+---------+------------+---------+------------------+
| bigmem    |   13   | Intel(R) Xeon(R)         |   48   | 1.47 TB |   816 GB   |  N/A    |2 days            |
|           |        | Gold 6248R CPU @ 3.00GHz |        |         |            |         |bigmem[01-13]     |
+-----------+--------+--------------------------+--------+---------+------------+---------+------------------+
| a100      |   496  | Intel(R) Xeon(R)         |   48   | 189 GB  |   91.4 TB  | 4*A100  |3 days            |
|           |        | Gold 6248R CPU @ 3.00GHz |        |         |            |         |gpu[01-10]        |
+-----------+--------+--------------------------+--------+---------+------------+---------+------------------+
| Total     |   519  |                          | 24,912 |         |            | 40*A100 |                  |
+-----------+--------+--------------------------+--------+---------+------------+---------+------------------+


 More defq nodes (about 8,500 cores) as well as a few bigmem and a100 nodes will be added to the Rockfish cluster.

-----------------------------------
Home, Data and Scratch File Systems
-----------------------------------

Users can use df command below to get a list of file systems mounted on a node:

.. code-block:: console
  [userid@login02 ~]$ df -h|grep -e 'Mounted' -e 'T'
  Filesystem                          Size  Used Avail Use% Mounted on
  storage01.ib.cluster:/s1draid/home   20T  2.8T   18T  14% /home
  master.ib.cluster:/cm/shared        1.9T  403G  1.5T  22% /cm/shared
  data                                5.2P  193T  5.0P   4% /data
  perf                                148T  6.9T  141T   5% /perf
  scratch16                           2.0P  689T  1.3P  36% /scratch16
  scratch4                            2.0P  250T  1.7P  13% /scratch4

Note: the size of the file systems will change in the near future.
