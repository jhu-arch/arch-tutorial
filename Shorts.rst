Short Tutorials
======================

They are straight to the point tutorials on Rockfish.

Python virtual environment
~~~~~~~~~~~~~~~~~~~~~~~~~~

.. image:: https://readthedocs.org/projects/python/badge/?version=latest
  :target: https://python.readthedocs.io/en/latest/?badge=latest
  :alt: The Python programming language

Here's an example of how to create a virtual Python environment using the built-in venv module in Python 3:

For more details, see. :ref:`Virtual Environment <virtual-env>`.

1. Connect to Rockfish terminal and navigate to the directory where you want to create the virtual environment.
2. Enter the following command to create a new virtual environment:

.. code-block:: console

  module load python/3.8.6
  python3 -m venv myenv

This will create a new virtual environment named myenv in the current directory.

3. Activate the virtual environment by running the appropriate command for your operating system:

.. code-block:: console

  source myenv/bin/activate

4. Once the virtual environment is activated, you can install any Python packages you need using pip. For example, to install the numpy package, simply run:

.. code-block:: console

  pip install numpy

5. When you're done working in the virtual environment, you can deactivate it by running the following command:

.. code-block:: console

  deactivate  

That's it! You've now created a virtual Python environment and installed a package inside it.

Anaconda virtual environment
~~~~~~~~~~~~~~~~~~~~~~~~~

.. image:: https://copr.fedorainfracloud.org/coprs/g/rhinstaller/Anaconda/package/anaconda/status_image/last_build.png
    :alt: Build status
    :target: https://copr.fedorainfracloud.org/coprs/g/rhinstaller/Anaconda/package/anaconda/

.. image:: https://readthedocs.org/projects/anaconda-installer/badge/?version=latest
    :alt: Documentation Status
    :target: https://anaconda-installer.readthedocs.io/en/latest/?badge=latest

.. image:: https://codecov.io/gh/rhinstaller/anaconda/branch/master/graph/badge.svg
    :alt: Coverage status
    :target: https://codecov.io/gh/rhinstaller/anaconda

.. image:: https://translate.fedoraproject.org/widgets/anaconda/-/master/svg-badge.svg
    :alt: Translation status
    :target: https://translate.fedoraproject.org/engage/anaconda/?utm_source=widget

Here's an example of how to create a new Conda environment using the conda create command:

1. Connect to Rockfish terminal.
2. Enter the following command to create a new Conda environment named myenv:

.. code-block:: console

  module load anaconda
  conda create --name myenv

You can also specify which version of Python you want to use by including the version number after the environment name. 
For example, to create a new environment named myenv with Python 3.9, you would enter:

.. code-block:: console

  conda create --name myenv python=3.9

3. Activate the new environment.

.. code-block:: console

  conda activate myenv

4. Once the environment is activated, you can install any Python packages you need using conda or pip. For example, to install the numpy package using conda, you would run:

.. code-block:: console

  conda install numpy

Alternatively, you can use pip to install packages:

.. code-block:: console

  pip install numpy

5. When you're done working in the environment, you can deactivate it by running the following command:

.. code-block:: console

  conda deactivate

That's it! You've now created a new Conda environment and installed a package inside it.

How to use python vend and conda env in slurm script
-----------------------------------------------------

To use a virtual environment created with either venv or conda in a Slurm script, you need to activate the environment before running your Python script. 

Here's how to do that:

Using a virtual environment created with venv:

.. code-block:: console

    #!/bin/bash
    #SBATCH --job-name=myjob
    #SBATCH --output=myjob.out
    #SBATCH --error=myjob.err
    #SBATCH --ntasks=1
    #SBATCH --cpus-per-task=1
    #SBATCH --time=1:00:00
    #SBATCH --partition=your_partition

    # Load any necessary modules or dependencies
    module load some_module

    # Activate the virtual environment
    source /path/to/venv/bin/activate

    # Run your Python script
    python myscript.py

    # Deactivate the virtual environment
    deactivate

Replace /path/to/venv with the path to your virtual environment directory, and myscript.py with the name of your Python script.

Using a virtual environment created with conda:

.. code-block:: console

    #!/bin/bash
    #SBATCH --job-name=myjob
    #SBATCH --output=myjob.out
    #SBATCH --error=myjob.err
    #SBATCH --ntasks=1
    #SBATCH --cpus-per-task=1
    #SBATCH --time=1:00:00
    #SBATCH --partition=your_partition

    # Load any necessary modules or dependencies
    module load conda
    module load some_module

    # Activate the virtual environment
    conda activate /path/to/env

    # Run your Python script
    python myscript.py

    # Deactivate the virtual environment
    conda deactivate

Replace /path/to/env with the path to your virtual environment directory, and myscript.py with the name of your Python script. 

Additionally, make sure to adjust the module load commands for any other modules or dependencies your Python script requires.

.. _conda-forge: https://docs.conda.io/projects/conda/en/latest/user-guide/tasks/manage-environments.html
.. _docs: https://conda.github.io/conda-pack/cli.html
.. _conda-forge: https://conda-forge.org/
.. _conda-pack: https://conda.github.io/conda-pack/
.. _Anaconda: https://anaconda.org


How to load Rockfish R submodules into an R session or R-Studio environment
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

In general, the ``module load`` command is used to load a specific software package or application into the current shell session. This command modifies the system's environment variables, such as ``PATH`` or ``LD_LIBRARY_PATH``, to make the software package available to the user.

.. note::
   `R`_ is an open-source programming language and software environment that is commonly used for statistical computing, data analysis, and visualization. By loading version ``4.0.2`` of ``R`` into the shell session, the user can run R scripts and commands, use R packages, and access other R-related functionality from within the terminal.

For instance, in this specific case, the ``module load`` command is being used to load version 4.0.2 of the R programming language into the current shell session on Rockfish. 

Here is an example of how to load a submodule for ``R/4.0.2``:

1. First, you would need to log in to a system where R/4.0.2 is installed and load the R module.

.. code-block:: console

  [userid@local ~]$ module load r/4.0.2

2. Next, you would start an **R session** by typing **R** at the command line. This will open the R command line interface.

3. Once you are in the **R** command line interface, you can use the **library()** function to load the desired submodule. For example, if you wanted to load the **ggplot2** package, which is a popular package for data visualization in R, you would type the following command:

.. code-block:: console

  > library(ggplot2)

This command loads the ``ggplot2`` package into the R session, making its functions and data available for use.

4. After you have finished using the submodule, you can unload it from the R session using the **detach()** function, to remove the ``ggplot2`` package from the R session, freeing up memory and preventing conflicts with other packages. 

.. code-block:: console

  > detach("package:ggplot2", unload=TRUE)

Overall, loading submodules in R/4.0.2 is a matter of using the **library()** function to load R packages within the R command line interface. The specific packages and submodules you load will depend on your specific needs and goals.

However, if the ``ggplot2`` package is not installed or not available, you will need to install it using the **install.packages()** command.

.. code-block:: console

  > install.packages("ggplot2")

This command will install the ``ggplot2`` package into the R session, making its functions and data available for use. 

Also, the easy way is to source the ``lmod.R`` script which will provide additional functionality for managing R modules in the **R session**, explained in the next section.


How to load R submodules available in the system in R session
--------------------------------------------------------------

the ``lmod.R`` script help to loads and executes submodules available in the system in R session.

.. note::
   This script is available in the /data/apps/helpers/ directory on Rockfish. It will change the **R_LIBS_USER** variable in R returning the paths where R looks for installed packages, the same way **module load** do in the terminal. When R searches for a package that has been loaded or installed, it will search in each of the directories listed by **.libPaths()** until it finds the package it is looking for.

Here is an example of how to use the ``lmod.R`` script to load a submodule for ``R/4.0.2``:

1. First, you would need to log in to a system where R/4.0.2 is installed and load the R module using the module load command.

.. code-block:: console

  [userid@local ~]$ module load r/4.0.2

2. Next, you would start an `R`_ session by typing **R** at the command line. This will open the R command line interface.

3. Once you are in the **R** command line interface, you can use the **source()** function to load the ``lmod.R`` script. For example:

.. code-block:: console

  > source("/data/apps/helpers/lmod.R")

.. tip::
    You can also use the **source()** function to load the ``lmod.R`` script from a different directory. For example:
  
    source(file.path(Sys.getenv("R_LIBS_USER"), "lmod.R"))

4. After you have sourced the ``lmod.R`` script, you can use the **lmod()** function to load the desired submodule. For example, if you wanted to load the **ggplot2** package, which is a popular package for data visualization in R, you would type the following command:

.. code-block:: console

  > module("load", "r/4.0.2")
  > module("load", "ggplot2")

This command loads the ``ggplot2`` package into the R session, making its functions and data available for use.

5. After you have finished using the submodule, you can unload it from the R session using the **lmod()** function. For example:

.. code-block:: console

  > module("unload", "ggplot2")

This command removes the ``ggplot2`` package from the R session, freeing up memory and preventing conflicts with other packages.

Overall, loading submodules in R/4.0.2 is a matter of using the **lmod.R** function to load R packages within the R command line interface. The specific packages and submodules you load will depend on your specific needs and goals.

However, if the ``ggplot2`` package is not installed, you need to install it using the **install.packages()** command. For example:

.. code-block:: console

  > install.packages("ggplot2")

This command will install the ``ggplot2`` package into the R session, making its functions and data available for use.

How to load tidyverse R submodule in R session
------------------------------------------------

.. code-block:: console

  [userid@local ~]$ module load r/4.0.2   
  [userid@local ~]$ R
 
  > module("load", "r-tidyverse")
  > library(tidyverse)

How to load R submodules and install Rsamtools package in R session
---------------------------------------------------------------------

.. code-block:: console

  [userid@local ~]$ module load r/4.0.2   
  [userid@local ~]$ R

.. warning::
    The **lmod.R** only works with **r/3.6.3** or **r/4.0.2**.

.. code-block:: console

  > source(file.path(Sys.getenv("R_LIBS_USER"), "lmod.R"))
  > module("load", "r/4.0.2")          
 
.. tip::
    Loading the r/4.0.2 will make R submodules available in the R session. 
    **Note**: It won't work if you use a different R version loaded in the terminal. Change the version as needed.

.. code-block:: console

    > module("load", "r-curl/4.3")
    > module("load","libjpeg")
    > module("load","libpng")
    > module("load","bzip2")
    > module("load","curl")

    > if (!require("BiocManager", quietly = TRUE))
        install.packages("BiocManager")
    > BiocManager::install("Rsamtools",dependencies=TRUE, force=TRUE)

    > library(Rsamtools)


How to load and and list submodule in R session
------------------------------------------------

.. code-block:: console

  [userid@local ~]$ module load r/3.6.3   
  [userid@local ~]$ R

  > module("load","r-ggplot2/3.2.0")
  > module("list")

  Currently Loaded Modules:
    1) gcc/9.3.0         10) r-lazyeval/0.2.2   19) r-magrittr/1.5      28) r-rcolorbrewer/1.1-2  37) r-ellipsis/0.3.0
    2) openmpi/3.1.6     11) r-mass/7.3-51.5    20) r-stringi/1.4.3     29) r-viridislite/0.3.0   38) r-zeallot/0.1.0
    3) slurm/19.05.7     12) r-lattice/0.20-38  21) r-stringr/1.4.0     30) r-scales/1.0.0        39) r-vctrs/0.2.0
    4) helpers/0.1.1     13) r-matrix/1.2-17    22) r-reshape2/1.4.3    31) r-assertthat/0.2.1    40) r-pillar/1.4.2
    5) git/2.28.0        14) r-nlme/3.1-141     23) r-rlang/0.4.6       32) r-crayon/1.3.4        41) r-pkgconfig/2.0.2
    6) standard/2020.10  15) r-mgcv/1.8-28      24) r-labeling/0.3      33) r-fansi/0.4.0         42) r-tibble/2.1.3
    7) r/3.6.3           16) r-rcpp/1.0.4.6     25) r-colorspace/1.4-1  34) r-cli/2.0.2           43) r-withr/2.2.0
    8) r-digest/0.6.25   17) r-plyr/1.8.4       26) r-munsell/0.5.0     35) r-utf8/1.1.4          44) r-ggplot2/3.2.0
    9) r-gtable/0.3.0    18) r-glue/1.4.1       27) r-r6/2.4.0          36) r-backports/1.1.4
  >

.. tip::
    You can also use the **module()** function to list all of the available modules in the current Lmod system. 
    For example:

    > module("avail") 

    > module("spider","r-")
    
    > module("list")

    This command lists all of the available modules in the current Lmod system. Running this command can be useful if you are not sure which module you need to load for a particular task.

.. _R: https://www.r-project.org/