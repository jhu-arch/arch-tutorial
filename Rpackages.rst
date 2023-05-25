Using R on the Rockfish
~~~~~~~~~~~~~~~~~~~~~~~

Running RStudio via Your Web Browser
************************************

Please go through the following link where all the information is available to start RStudio Server via web browser.

  https://www.arch.jhu.edu/user-guide/#elementor-tab-title-1606

Research Computing OnDemand
***************************

RStudio is available on OpenOnDemand portal. You will need to use a VPN to connect from off-campus (PulseSecure VPN).  To begin a session, click on "Interactive Apps" and then "RStudio Server". For more details see the User Guide from ARCH website. Following link is helpful.

  https://www.arch.jhu.edu/user-guide/#elementor-tab-title-1608

OpenOnDemand portal link:

  https://portal.rockfish.jhu.edu/

QUICK RUN
*********

To install a common R package then try this:

.. code-block:: console

  $ module load r/4.0.2
  $ R
  > install.packages("<package-name>")

  e.g.,

.. code-block:: console

  install.packages("hdf5r")

VERSION 3.6.3 vs. 4.0.2
^^^^^^^^^^^^^^^^^^^^^^^

As of now, the default version of R on Rockfish is 4.0.2. To use another version 3.6.3, run the following command on the command line or in your Slurm script:

.. code-block:: console

  module load r/3.6.3
  OR
  module load r/4.0.2

Once you load r-module (e.g.; ml r/4.0.2) and type module avail command to see other r-packages available as modules. You will be able to see plenty of other packages installed as a module as below. You can directly load the module and use that package for your workflow.

.. code-block:: console

  ------------------------------------------------ R (4.0) ------------------------------------------------
     r-acepack/1.4.1                  r-htmltools/0.3.6        r-rcpp/1.0.4.6
     r-askpass/1.1                    r-htmlwidgets/1.3        r-rcppeigen/0.3.3.5.0
     r-assertthat/0.2.1               r-httpuv/1.5.1           r-rematch2/2.1.2
     r-backports/1.1.4                r-httr/1.4.1             r-remotes/2.1.1
     r-base64enc/0.1-3                r-ini/0.3.1              r-reshape2/1.4.3
     r-bh/1.69.0-1                    r-inline/0.3.15          r-rex/1.1.2
     r-biocgenerics/0.34.0            r-intervals/0.15.1       r-rlang/0.4.6
     r-brew/1.0-6                     r-iranges/2.22.2         r-roxygen2/7.1.0
     r-cairo/1.6.0                    r-iterators/1.0.12       r-rpart/4.1-15
  …………
  …………

We have other modules are available on Rockfish which have their own R.

  module load Seurat/3.0.2 (R-version is 3.6.3)
  module load Seurat/3.2.3 (R-version is 4.0.5)
  module load Seurat/4.1.1 (R-version is 4.1.3)
  module load edgeR/3.38.1 (R-version is 4.2.0)

  Installing R Packages
  """""""""""""""""""""

  From the source file:
  """""""""""""""""""""

.. code-block:: console

  $ module load r/4.0.2
  $ R
  > install.packages("https://raw.githubusercontent.com/matthew-zahn/VPcpp/main/VPcpp_1.0.tar.gz", repos=NULL, type="source")

You can also manually download package from its website. Most popular packages are part of the CRAN archive. E.g.;

.. code-block:: console

  wget https://cran.r-project.org/src/contrib/LearnBayes_2.15.1.tar.gz

The package can now be installed by loading the R module and running R CMD INSTALL. Also specify the -l flag for a local install, the directory where you wish to install in and finally the name of the package file we just downloaded.

.. code-block:: console

  $ module load r/4.0.2
  $ R CMD INSTALL -l <path_to_library> LearnBayes_2.15.1.tar.gz

You will have to tell R where to find the installed libraries. Set the R_LIBS_USER environment variable with export command. You might require adding this command to any Slurm scripts which you write for using with R.

.. code-block:: console

  $ export R_LIBS_USER=<path_to_installation>

After installation of R-Packages, you require to load that package.
The R command to load a general package is

.. code-block:: console

  $ module load r/4.0.2
  $ R
  > library("R-Package")

Specify the local path to the R package while loading the library. To load a locally installed R package, use the library command with parameter lib.loc as

.. code-block:: console

  $ module load r/4.0.2
  $ R
  > library("myRPackage", lib.loc="<path_to_library>")

Check the installed version of the package

.. code-block:: console

  > packageVersion("myRPackage")

Using Conda
"""""""""""

Creating the Conda environment is another way to install R-packages and for R itself. You can search for these packages on anaconda.org.
For example, create a Conda environment that includes r-hdf5r and other packages:

.. code-block:: console

  $ module load anaconda
  $ conda create --name hdf5r
  $ conda activate hdf5r
  $ conda install -c conda-forge r-hdf5r
  $ R
  > q()

You can also install other R-packages in same conda environment.
e.g.

.. code-block:: console

  $ conda activate hdf5r
  $ conda install -c conda-forge r-hdf5r
  $ conda install -c bioconda bioconductor-limma
  $ conda install -c conda-forge r-patchwork

Note that a Conda environment composed of R-packages comes with its own R executable. Make sure that you are loading the anaconda module and activate the environment.

Install R-packages in your local library to any path

.. code-block:: console

  $ ml r/4.0.2
  $ export R_LIBS_USER= <path-to-installation>
  $ R
  > install.packages(“<package_name>”, lib=”<path_to_installation>”)
  OR
  > install.packages(“<package_name>”)
  OR
  > BiocManager::install('spatialLIBD', lib=Sys.getenv("R_LIBS_USER"))

For example:

.. code-block:: console

  > devtools::install_github("davidaknowles/leafcutter/leafcutter", lib="/home/apate168/R/4.1.3")
