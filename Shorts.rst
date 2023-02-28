Short Tutorials
###############

They are straight to the point tutorials on Rockfish.

Python virtual environment
**************************


.. image:: https://readthedocs.org/projects/python/badge/?version=latest
  :target: https://python.readthedocs.io/en/latest/?badge=latest
  :alt: The Python programming language

Here's an example of how to create a virtual Python environment using the built-in venv module in Python 3:

For more details and explanation, see. :ref:`Virtual Environment <virtual-env>`.

1. Open your terminal or command prompt and navigate to the directory where you want to create the virtual environment.
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
****************************

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

1. Open your terminal or command prompt.
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
****************************************************

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
