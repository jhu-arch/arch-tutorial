Singularity
###########

This tutorial is for running `Singularity`_ on a computer where you do not have root (administrative) privileges, like the Rockfish cluster at ARCH.

We will prepare an image using `Docker container`_, and make it available on `Docker Hub`_ and then an administrator will create a Singularity container to run it on Rockfish.

In order to build the application, we need to use a Dockerfile, using `Nanopolish`_ as an example. It is a software package for signal-level analysis of Oxford Nanopore sequencing data.

.. note::
  There are different ways to run Nanopolish: via conda, via installation source or container. This tutorial will cover how to install it using singularity, via docker hub repository.

.. _Nanopolish: https://github.com/jts/nanopolish
.. _Singularity: https://singularity-user-docs.readthedocs.io/en/latest/quick_start.html
.. _Docker container: https://docs.docker.com
.. _Docker Hub: https://hub.docker.com


## Nanopolish

The Nanopolish package calculates an improved consensus sequence for a draft genome assembly, detect base modifications, call SNPs and indels with respect to a reference genome and more modules.

.. note::
  To create this this container, we used the latest Nanopolish version 0.13.3 and Ubuntu 21.04. Also, you can use different platform GNU/Linux, Ubuntu, ArchLinux, Debian, Centos, etc.

Non-root users:
***************

The next steps were used to create it.

  1. Dockerfile
  2. Docker build
  3. Docker run
  4. Docker start
  5. Docker exec
  6. Docker commit
  7. Docker push

Root users
**********

The next steps used to create it on Rockfish, after completing Non-root users steps.

.. code-block:: console

  [userid@login03 ~]$ interact -c 2 -t 120
  [userid@c010 ~]$ sudo singularity build nanopolish.sif docker://archrockfish/nanopolish:0.13.3

1. Create a file named `Dockerfile`_
************************************

Docker builds images automatically by reading the instructions from a ``Dockerfile``.

.. note::
  Dockerfile is a text file that contains all commands, in order, needed to build a given image.

.. code-block:: console

  FROM --platform=linux/amd64 ubuntu:21.04

  MAINTAINER Ricardo S. Jacomini <rdesouz4@jhu.edu>

  RUN uname -a

  ENV TZ=America/New_York

  RUN apt-get update -qq

  RUN apt-get install -y tzdata

  RUN ln -fs /usr/share/zoneinfo/$TZ /etc/localtime && dpkg-reconfigure -f noninteractive tzdata

  RUN date

  RUN apt-get install -yq --no-install-suggests --no-install-recommends \

      ca-certificates gcc g++ make git wget bzip2 libbz2-dev \

      zlib1g-dev liblzma-dev libncurses5-dev libncursesw5-dev xz-utils \

      bwa bedtools \

      software-properties-common

  # **** Install HTSLIB ****

  RUN wget https://github.com/samtools/htslib/releases/download/1.9/htslib-1.9.tar.bz2

  RUN tar -vxjf htslib-1.9.tar.bz2

  WORKDIR htslib-1.9

  RUN ./configure --prefix=/usr/local

  RUN make

  RUN make install

  WORKDIR /

  RUN rm htslib* -Rf

  # **** Install BCFTools ****

  WORKDIR /

  RUN wget https://github.com/samtools/bcftools/releases/download/1.9/bcftools-1.9.tar.bz2

  RUN tar -vxjf bcftools-1.9.tar.bz2

  WORKDIR bcftools-1.9

  RUN ./configure --prefix=/usr/local

  RUN make

  RUN make install

  WORKDIR /

  RUN rm bcftools* -Rf

  # **** Install Canu ****

  WORKDIR /opt

  RUN git clone https://github.com/marbl/canu.git

  WORKDIR canu/src

  RUN make -j 4

  WORKDIR /

  # **** Set up environment variable ****

  ENV PATH="/opt/nanopolish:/opt/nanopolish/bin:/opt/canu/build/bin/:$PATH"

  ENV LD_LIBRARY_PATH="/opt/nanopolish/lib:$LD_LIBRARY_PATH"

  ENV C_INCLUDE_PATH ="/opt/nanopolish/include:$LD_LIBRARY_PATH">

  # **** Install Nanopolish ****

  WORKDIR /opt

  RUN git clone --recursive https://github.com/jts/nanopolish.git

  WORKDIR /opt/nanopolish

  RUN make all

  RUN make test

  RUN rm *.tar.*


2. `Build`_ an image from a Dockerfile
**************************************

  **Usage** : $ `docker`_ build [OPTIONS] PATH | URL | -

.. code-block:: console

  [userid@local ~]$  docker build - < Dockerfile


3. Create a `tag`_ `TARGET_IMAGE` that refers to `SOURCE_IMAGE`.
****************************************************************

  **Usage** : $ docker tag SOURCE_IMAGE[:TAG] TARGET_IMAGE[:TAG]

Tag an image referenced by ID.

.. code-block:: console

  [userid@local ~]$ docker image ls
  REPOSITORY                               TAG               IMAGE ID       CREATED          SIZE
  <none>                                   <none>            540135da7ceb   47 minutes ago   1.96GB

  [userid@local ~]$ docker tag 540135da7ceb archrockfish/nanopolish:0.13.3

  [userid@local ~]$ docker image ls
  REPOSITORY                               TAG               IMAGE ID       CREATED        SIZE
  archrockfish/nanopolish                  0.13.3            540135da7ceb   49 minutes ago   1.96GB

4. `Run`_ a command in a new container
**************************************

  **Usage** : $ docker run [OPTIONS] IMAGE [COMMAND] [ARG...]

Run it will create a container and start a Bash session to a specified image using IMAGE ID.

.. code-block:: console

  [userid@local ~]$ docker run --name -it 540135da7ceb bash
  root@421451a1f942:/opt/nanopolish#

  [userid@local ~]$ docker ps -all
  CONTAINER ID   IMAGE          COMMAND   CREATED          STATUS                     PORTS     NAMES
  421451a1f942   540135da7ceb   "bash"    22 seconds ago   Exited (0) 5 seconds ago             stupefied_johnson

or you can Run it will create a container named nanopolish using REPOSITORY, if it was tagged. (`step 3`)

.. code-block:: console

  [userid@local ~]$ docker run --name nanopolish -it archrockfish/nanopolish:0.13.3 bash
  root@0c192de0b227:/#

  [userid@local ~]$ docker ps --all
  CONTAINER ID   IMAGE                            COMMAND   CREATED         STATUS          PORTS     NAMES
  0c192de0b227   archrockfish/nanopolish:0.13.3   "bash"    3 minutes ago   Up 44 seconds             nanopolish

5. `Start`_ one or more stopped containers
******************************************

  **Usage** : $ docker start [OPTIONS] CONTAINER [CONTAINER...]

.. code-block:: console

  [userid@local ~]$ docker start nanopolish
  nanopolish

  [userid@local ~]$ docker ps
  CONTAINER ID   IMAGE          COMMAND   CREATED          STATUS         PORTS     NAMES
  0c192de0b227   540135da7ceb   "bash"    46 seconds ago   Up 5 seconds             nanopolish

6. `Exec`_ (perform) a command into a running container
*******************************************************

  **Usage** : $ docker exec [OPTIONS] CONTAINER COMMAND [ARG...]

First, start a container (`step 5`), or keep the container running (`step 4`) in the background, to run it with `--detach` (or `-d`) argument.

.. note::
  You need to delete that first before you can re-create a container with the same name with.

.. code-block:: console

  [userid@local ~]$  docker stop nanopolish
  nanopolish

  [userid@local ~]$  docker rm nanopolish
  nanopolish
  or simply choose a different name for the new container.

  [userid@local ~]$ docker run --name nanopolish_local -dit archrockfish/nanopolish:0.13.3
  a3dcaa7760906861250329dca37b01f79caec10310e1bc37b7fdf6f341de5d27
  Then, execute an interactive bash shell on the new container.

  [userid@local ~]$ docker exec -it nanopolish_local bash
  root@a3dcaa776090:/opt/nanopolish#


7. Create a new image from a container’s changes
************************************************

  **Usage** : $ docker `commit`_ [OPTIONS] CONTAINER [REPOSITORY[:TAG]]

.. code-block:: console

  [userid@local ~]$ docker ps -all
  CONTAINER ID   IMAGE                            COMMAND   CREATED          STATUS                      PORTS     NAMES
  a3dcaa776090   archrockfish/nanopolish:0.13.3   "bash"    18 seconds ago   Exited (0) 14 seconds ago             nanopolish_local

  [userid@local ~]$  docker commit a3dcaa776090 archrockfish/nanopolish:0.13.3
  sha256:b379b32916535b146b1fce63a14fade2cdf60bbaacf36625732cec379e03dd96

  [userid@local ~]$ docker inspect -f "{{ .Config.Env }}" a3dcaa776090
  [PATH=/opt/nanopolish:/opt/nanopolish/bin:/opt/canu/build/bin/:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin TZ=America/New_York LD_LIBRARY_PATH=/opt/nanopolish/lib: C_INCLUDE_PATH==/opt/nanopolish/include:/opt/nanopolish/lib:]

  [userid@local ~]$ docker image ls
  REPOSITORY                               TAG               IMAGE ID       CREATED         SIZE
  archrockfish/nanopolish                  0.13.3            0375e5f8a31d   4 minutes ago   1.96GB

8. `Push`_ an image or a repository to a registry
*************************************************

  **Usage** : $ docker push [OPTIONS] NAME[:TAG]

.. code-block:: console

  [userid@local ~]$ docker push archrockfish/nanopolish:0.13.3
  The push refers to repository [docker.io/archrockfish/nanopolish]
  ee33934ad57b: Layer already exists
  ...
  ...
  ...

.. warning::
  You need to create a repository and assign who are the `contributors`_ with permission to upload an image to this repository.

.. _Dockerfile: https://docs.docker.com/develop/develop-images/dockerfile_best-practices/
.. _docker: https://docs.docker.com/engine/reference/builder/
.. _Build: https://docs.docker.com/engine/reference/commandline/build/
.. _tag: https://docs.docker.com/engine/reference/commandline/tag/
.. _Run: https://docs.docker.com/engine/reference/commandline/run/
.. _Start: https://docs.docker.com/engine/reference/commandline/start/
.. _Exec: https://docs.docker.com/engine/reference/commandline/exec/
.. _commit: https://docs.docker.com/engine/reference/commandline/commit/
.. _Push: https://docs.docker.com/engine/reference/commandline/push/
.. _contributors: https://docs.docker.com/docker-hub/repos/
