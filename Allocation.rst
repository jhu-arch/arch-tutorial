Allocation / Account Management
###############################

* Rockfish `Portal`_

  * Account / Allocation request (PI)
  * User account request
  * Password reset
  * Management / add / delete accounts
  * ROI: upload pubications, grants
  * Account / Allocation request (PI
  * Video -> Rockfish portal `navigation`_

.. _Portal: https://coldfront.rockfish.jhu.edu/
.. _navigation: https://www.youtube.com/watch?v=L6zvLBK5Mss

Please refer to `allocations`_ web site.

.. _allocations: https://www.arch.jhu.edu/policies/allocations

Storage Allocations
*********************

.. csv-table:: Storage Allocations
   :header: File Systems,Quota (default),Usage,Back-Up,System Type
   :widths: 30, 12, 21, 10, 20

   HOME (/home/<user id>),50 GB (per user),Keep commonly used applications,backed up on a weekly basis to an off-site location,NMVe SSD
   data (/data/<PI-userid>),10 TB (per group),Store files for a longer time,N/A,GPFS (parallel file system)
   scratch16 (/scratch16/<PI-userid>),10 TB (per group),Scratch for large files,N/A,GPFS (parallel file system 16MB blocksize)
   scratch4 (/scratch4/<PI-userid>),10 TB (per group),Scratch for small files,N/A,GPFS (parallel file system 4MB block size)

.. note::
  The ``<userid>`` is the user's account name and ``<PI-userid>`` is the account name of the user's PI.
