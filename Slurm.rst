Slurm
#####

* interact -usage
* interact-p defq -n 12 -t 120


Request Interactive jobs
************************

It is helpful to run your work and get the response of the commands right away to see if any error is in your workflow. If an interactive job is required for job testing, users can use the interact command to request one. Simply use the command on a login node to display the usage.

.. code-block:: console

  [userid@login02 ~]$ interact

  usage: interact [-n tasks or cores]  [-t walltime] [-r reservation] [-p partition] [-a Account] [-f featurelist] [-h hostname] [-g ngpus]

  Starts an interactive job by wrapping the SLURM 'salloc' and 'srun' commands.

  options:
    -n tasks        (default: 1)
    -m memory       memory in K|M|G|T (if m > max-per-cpu * cpus, more cpus are requested)
    -t walltime     as hh:mm:ss (default: 30:00)
    -r reservation  reservation name
    -p partition    (default: 'defq')
    -a Account      If users needs to use a different account. Default is primary PI
    -f featurelist  SLURM features (e.g., 'haswell'),
                    combined with '&' and '|' (default: none)
    -h hostname     only run on the specific node 'hostname'
                    (default: none, use any available node)
    -g gpus         specify GRES for GPU-based resources

As mentioned in the results, this command is related to 'salloc' and 'srun' commands. We can see how it works by requesting an interactive job:

.. code-block:: console

  [userid@login03 ~]$ interact -n 1
  Tasks:    1
  Cores/task: 1
  Total cores: 1
  Walltime: 30:00
  Reservation:
  Queue:    defq
  Command submitted: salloc -J interact -N 1-1 -n 1 --time=30:00 -p defq srun --pty bash
  salloc: Granted job allocation 3624855
  ... ... ...
  ... ... ...

  [userid@c003 ~]$

where the real command executed is:

.. code-block:: console

  [userid@login02 ~]$ salloc -J interact -N 1-1 -n 1 --time=30:00 -p defq srun --pty bash

In other words, the interact command uses the syntax:

``salloc <Job Options> srun --pty bash``to request an interactive job. A list of available job options is mentioned in the next section, and we can use them for job submission.

Here is a example to to request an interactive mode to GPU node.

.. code-block:: console

  [userid@login02 ~]$ salloc -J test -N 1 -n 12 --time=1:00:00 -p a100 -q qos_gpu -A <PI-userid_gpu> --gres=gpu:1 srun --pty bash
