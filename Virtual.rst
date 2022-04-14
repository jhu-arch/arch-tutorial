Virtual Environment
###################

Reproducibility is an important characteristic of a good data science project. 

Python
******

PIP
^^^

pip is a package manager.

Anaconda
********

The Rockfish cluster also has versions of anaconda installed. After you load a version of anaconda, you can use conda command to create conda environments and install python packages.

.. code-block:: console

  [userid@login03 conda]$ module load anaconda
  [userid@login03 conda]$ conda -V
  conda 4.8.3

Users are suggested to use conda environments for installing and running packages as mentioned in the python section.

Conda
^^^^^
Conda is a tool to manager virtual environments, it allows to create, removing or packaging virtual environments, as well as package manager.

Conda-Pack
^^^^^^^^^^
=conda-pack`_ is a command line tool for creating relocatable conda environments. This is useful for deploying code in a consistent environment, potentially in a location where python/conda isn't already installed.

Install via conda

conda-pack is available from `Anaconda`_ as well as from conda-forge:

.. code-block:: console

  conda install conda-pack
  conda install -c conda-forge conda-pack

Install via pip

While conda-pack requires an existing conda install, it can also be installed from PyPI:

.. code-block:: console

  pip install conda-pack

Install from source

It can be installed from source.

.. code-block:: console

  pip install git+https://github.com/conda/conda-pack.git

**Usage**

conda-pack is primarily a commandline tool, see `docs`_ for full details.

On the source machine
"""""""""""""""""""""

.. code-block:: console

  # Pack environment my_env into my_env.tar.gz
  $ conda pack -n my_env

  # Pack environment my_env into out_name.tar.gz
  $ conda pack -n my_env -o out_name.tar.gz

  # Pack environment located at an explicit path into my_env.tar.gz
  $ conda pack -p /explicit/path/to/my_env

On the target machine
"""""""""""""""""""""

.. code-block:: console

  # Unpack environment into directory `my_env`
  $ mkdir -p my_env
  $ tar -xzf my_env.tar.gz -C my_env

  # Use python without activating or fixing the prefixes. Most python
  # libraries will work fine, but things that require prefix cleanups
  # will fail.
  $ ./my_env/bin/python

  # Activate the environment. This adds `my_env/bin` to your path
  $ source my_env/bin/activate

  # Run python from in the environment
  (my_env) $ python

  # Cleanup prefixes from in the active environment.
  # Note that this command can also be run without activating the environment
  # as long as some version of python is already installed on the machine.
  (my_env) $ conda-unpack

  # At this point the environment is exactly as if you installed it here
  # using conda directly. All scripts should work fine.
  (my_env) $ ipython --version

  # Deactivate the environment to remove it from your path
  (my_env) $ source my_env/bin/deactivate


.. _docs: https://conda.github.io/conda-pack/cli.html
.. _conda-forge: https://conda-forge.org/
.. _conda-pack: https://conda.github.io/conda-pack/
.. _Anaconda: https://anaconda.org
