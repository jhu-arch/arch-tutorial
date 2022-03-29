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

Batch Job Script
****************

To submit a batch job and run it on a compute node, users need to use sbatch command with a job script file.
The job script is supposed to contain three parts:
**1**. The first line of the file which specifies the shell to run the script ``#!/bin/bash``. **2**. second part contains the lines of resource requests and job options. Each of the lines must start with the words ``#SBATCH`` so the job scheduler (SLURM) can read and manage the resources.

.. code-block:: console

  # Part 1       ( `Shell script instruction`_ )
  #!/bin/bash

  # Part 2       ( `SLURM input environment variables`_ )
  #SBATCH --job-name=MyTest                    # Job name (-J MyTest)
  #SBATCH --time=4:00:00                       # Time limit (-t 4:00:00)
  #SBATCH --nodes=1                            # Number of nodes (-N 1)
  #SBATCH --ntasks=2                           # Number of processors (-n 2)
  #SBATCH --cpus-per-task=6                    # Threads per process (-c 6)
  #SBATCH --partition=defq                     # Used partition (-p defq)
  #SBATCH --mem-per-cpu=4GB                    # Define memory per core

  # Part 3      ( `Loading and Unloading Modules`_ )
  module load intel/2020.2 intel-mpi/2020.2
  module load quantum-espresso/6.6

  export OMP_NUM_THREADS=${SLURM_CPUS_PER_TASK}
  mpirun -n $SLURM_NTASKS pw.x < scf.in > scf.out

  scontrol show job $SLURM_JOBID

.. _Loading and Unloading Modules: https://www.arch.jhu.edu/access/user-guide/
.. _Shell script instruction: https://www.tutorialspoint.com/unix/unix-getting-started.htm
.. _Slurm input environment variables: https://slurm.schedmd.com/sbatch.html

This example above will use 2 processes simultaneously (in parallel) on one node in the ``defq` partition with 6 threads in each process. The maximum memory usage is 4GB per CPU and maximum running time is 4 hours. The third part is the command lines which will be run on the compute nodes when the job starts.
The command lines should include all commands of job workflow after logging into a node, such as module loading, environment setting and running application commands.

The first 2 command lines load the necessary modules to run the QuantumESPRESSO software. The export command sets the environment variable ``OMP_NUM_THREADS`input  as the SLURM environment variable ``SLURM_CPUS_PER_TASK`` which is the requested number of CPUs per task. The setting allows the application to run with multiple threads. The mpirun command starts to run the ``pw.x`` command in parallel with the number of the processes the same as the SLURM variable ``$SLURM_NTASKS`` set to be the requested number of tasks. The last command will print the job information to the SLURM output file, where the environment variable ``$SLURM_JOBID`` is set to be the job ID of the job. More SLURM variables can be seen in the SLURM Environment Variables section.
By default, the job standard output and standard error will be sent to the SLURM output file ``slurm-<JobID>.out`` in the directory where you run the job submission command. Users can use the ``-o`` or ``-e`` option to specify a different output or a different error file name with a preferred location. If the ``-e`` option is not specified, both messages are sent to the output file. Users can also use the filename pattern to name the file. For example, using the specifications:

.. code-block:: console

  #SBATCH -o /home/userid/%j/%x.out
  #SBATCH -e /home/userid/%j/%x.err

It will send the output to the file ``/home/userid/<JobID>/<JobName>.out`` and the error to the file ``/home/userid/<JobID>/<JobName>.err` , where ``<JobID>`` and ``<JobName>`` are the ID and name of the job respectively.

If there exists a file with the same file name as the output file name, the job output will append to it.
