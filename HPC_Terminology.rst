HPC Terminology
###############

This is a high-level overview of features on the Rockfish Cluster at ARCH.

`**ARCH**`_

The Advanced Research Computing at Hopkins (ARCH) –formerly known as MARCC– is a shared computing facility at Johns Hopkins University that enables research, discovery, and learning, relying on the use and development of advanced computing.

.. _ARCH: https://www.arch.jhu.edu/about-rockfish/

**Node**

A standalone "computer in a box". Usually comprised of multiple CPUs/processors/cores, memory, network interfaces, etc.

**Cluster**

A group of nodes networked together so a program can run on them in parallel.

**CPU/Processor(Socket)/Core**

In the past, a CPU (Central Processing Unit) was a singular execution component for a computer. Then, multiple-core CPU is incorporated into a node. It is subdivided into multiple "cores" inside processors (or sockets). Each core is a unique execution unit like a CPU in the past. RAM memory between different sockets is connected with a bus interface.

.. image:: images/picture1.png
  :width: 800
  :alt: Multicore CPU (NUMA system)

**GPU**

Short for Graphics Processing Unit. It is a specialized processor with thousands of small CPU cores. It can run multiple processes and perform many pieces of data in parallel. It is useful for machine learning, video editing, and gaming applications.

**HPC**

High Performance Computing

**Slurm**

Slurm is an open source, fault-tolerant, and highly scalable cluster management and job scheduling system for large and small Linux clusters.

**Task/Process**

A process or running process refers to a set of programmed instructions currently being processed by the computer CPU. A process may be made up of multiple threads of execution that execute instructions concurrently.
