Hardware Resources
##################

+-----------+--------------------------+-------+--------------------------+--------+---------+------------+---------+------------------+
| Partition |  `Running Jobs`_         | Nodes |  Processors              | Cores  | Memory  | Local Disk |  GPUs   |  Job Time Limit  |
|           |                          |       |                          |        |         |            |         |  & Node Names    |
+===========+==========================+=======+==========================+========+=========+============+=========+==================+
| defq      | all regular memory nodes |  496  | Intel(R) Xeon(R)         |   48   | 189 GB  |   915 GB   |   N/A   |3 days            |
|           |                          |       | Gold 6248R CPU @ 3.00GHz |        |         |            |         |c[001-232,241-280,|
|           |                          |       |                          |        |         |            |         |289-328,337-376,  |
|           |                          |       |                          |        |         |            |         |385-424,433-440,  |
|           |                          |       |                          |        |         |            |         |625-720]          |
+-----------+--------------------------+-------+--------------------------+--------+---------+------------+---------+------------------+
| bigmem    | all Large memory         |  13   | Intel(R) Xeon(R)         |   48   | 1.47 TB |   816 GB   |         |2 days            |
|           | (1524GB)                 |       | Gold 6248R CPU @ 3.00GHz |        |         |            |         |bigmem[01-13]     |
+-----------+--------------------------+-------+--------------------------+--------+---------+------------+---------+------------------+
| a100      | all GPU nodes            |  10   | Intel(R) Xeon(R)         |   48   | 189 GB  |   91.4 TB  | 4*A100  |3 days            |
|           | 4 Nvidia A100 per node   |       | Gold 6248R CPU @ 3.00GHz |        |         |            |         |gpu[01-10]        |
+-----------+--------------------------+-------+--------------------------+--------+---------+------------+---------+------------------+
| **Total** |                          |**519**|                          |**24,912**|         |            |**40*A100**|              |
+-----------+--------------------------+-------+--------------------------+--------+---------+------------+---------+------------------+

.. _Running Jobs: https://www.arch.jhu.edu/access/user-guide/

More defq nodes (about 8,500 cores) as well as a few bigmem and a100 nodes will be added to the Rockfish cluster.

Home, Data and Scratch File Systems
***********************************

Users can use ``df`` command below to get a list of file systems mounted on a node:

.. code-block:: console

  [userid@login02 ~]$ df -h | grep -e 'Mounted' -e 'T'
  Filesystem                          Size  Used Avail Use% Mounted on
  storage01.ib.cluster:/s1draid/home   20T  2.8T   18T  14% /home
  master.ib.cluster:/cm/shared        1.9T  403G  1.5T  22% /cm/shared
  data                                5.2P  193T  5.0P   4% /data
  perf                                148T  6.9T  141T   5% /perf
  scratch16                           2.0P  689T  1.3P  36% /scratch16
  scratch4                            2.0P  250T  1.7P  13% /scratch4

Note: the size of the file systems will change in the near future.

Check Storage and Account Allocations
*************************************

To check the allocation and usage of their job accounts, users can use sbalance command.

.. code-block:: console

$ sbalance
[USAGE] sbalance slurm_account [username]

$ sbalance PI-userid userid
[BALANCE] used/quarter, account:         PI-userid 64406.4 / 143750.0 (SU)
[BALANCE] used/quarter, user:            userid 9468.7 / 143750.0 (SU)





Software
********

You can use various software with different versions installed in HPCC:

*	Compilers —   GNU, intel, CUDA, ...
* Parallel  —   OpenMPI, Intel-MPI, ...
* Bioinformatics  —  BLAST, Trinity, Mothur, Samtools, Trimmomatic, ...
* Libraries  —  MKL, OpenBLAS, HDF5ls , FFTW, ...
* Commercial  —  MATLAB, ABINIT, COMSOL, TotalView, ...
