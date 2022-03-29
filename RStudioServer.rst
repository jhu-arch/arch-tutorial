RStudio Server
##############

The open-source RStudio Server provides a fully-featured IDE for R users.

The users can access RStudio Server on Rockfish using the r-studio-server.sh command. It will submit a SLURM job to system.

Usage examples to start the RStudio service:

.. code-block:: console

  $ r-studio-server.sh -h
  $ r-studio-server.sh -n 1 -c 2 -m 4G -t 0-02:0:0 -p defq (default)
  $ r-studio-server.sh -c 2 -t 4:0:0 -p defq -e <userid>@jhu.edu
