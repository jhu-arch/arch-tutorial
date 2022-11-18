#!/bin/bash

startdate="2022-06-01"
enddate="2022-06-01"

#!/bin/bash

startdate=$1
enddate=$2

sacct --allusers --parsable2 --noheader --allocations --clusters slurm --format jobid,jobidraw,cluster,partition,account,group,gid,user,uid,submit,eligible,start,end,elapsed,exitcode,state,nnodes,ncpus,reqcpus,reqmem,ReqTRES,reqtres,timelimit,nodelist,jobname --state CANCELLED,COMPLETED,FAILED,NODE_FAIL,PREEMPTED,TIMEOUT --starttime $startdate --endtime $enddate > report_$enddate



/data/rdesouz4/slurm/report

sacct_report.sh 2022-06-01 2022-07-01

sed -i 's/slurm/Rockfish/g' 


plot python vs XDMoD


salloc -J interact -N 1-1 -n 1 --time=30:00 --gres=gpu:res=gpu:1 -p a100 --qos=qos_gpu -A jtrmal1_gpu srun --pty bash

salloc -J interact -N 1-1 -n 1 --time=30:00 --gres=gpu:res=gpu:1 -p a100 --qos=qos_gpu srun --pty bash


pip install SoundFile
pip install faiss

ml seurat/3.2.3
export MY_LIBS=test
export R_LIBS_USER=${HOME}/R/${MY_LIBS}


library(Seurat)
library(SeuratObject)
library(SeuratDisk)
library(sctransform)
library(loomR)

lfile <- connect(filename = "/home/ext-mariatriantafyllou/R_training/progenitor-marrow-human-spleen-10XV2.loom", mode = "r+", skip.validate = TRUE)


https://hpc.guix.info


sacct_monthly.sh 2021-01-01 2021-02-01
sacct_monthly.sh 2021-02-01 2021-03-01
sacct_monthly.sh 2021-03-01 2021-04-01
sacct_monthly.sh 2021-04-01 2021-05-01
sacct_monthly.sh 2021-05-01 2021-06-01
sacct_monthly.sh 2021-06-01 2021-07-01
sacct_monthly.sh 2021-07-01 2021-08-01
sacct_monthly.sh 2021-08-01 2021-09-01
sacct_monthly.sh 2021-09-01 2021-10-01
sacct_monthly.sh 2021-10-01 2021-11-01
sacct_monthly.sh 2021-11-01 2021-12-01
sacct_monthly.sh 2021-12-01 2022-01-01
sacct_monthly.sh 2022-01-01 2022-02-01
sacct_monthly.sh 2022-02-01 2022-03-01
sacct_monthly.sh 2022-03-01 2022-04-01
sacct_monthly.sh 2022-04-01 2022-05-01
sacct_monthly.sh 2022-05-01 2022-06-01
sacct_monthly.sh 2022-06-01 2022-07-01
sacct_monthly.sh 2022-07-01 2022-08-01
sacct_monthly.sh 2022-08-01 2022-09-01
sacct_monthly.sh 2022-09-01 2022-10-01
sacct_monthly.sh 2022-10-01 2022-11-01