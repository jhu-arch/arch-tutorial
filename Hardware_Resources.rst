Hardware Resources





     =====  =====  ======
        Inputs     Output
     ------------  ------
       A      B    A or B
     =====  =====  ======
     False  False  False
     True   False  True
     False  True   True
     True   True   True
     =====  =====  ======

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
