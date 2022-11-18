#!/bin/bash

if [ $# -eq 0 ] ; then
  yesterdayfile=$(date --date="yesterday" +%Y%m%d)
  yesterday=$(date --date="yesterday" +%m/%d/%y)
  today=$(date +%m/%d/%y)
elif [ $# -eq 1 ] ; then
  # e.g. 20180101
  # e.g. 1,2,3,4 
  yesterdayfile=$(date -d "$1 days ago" +%Y%m%d)
  yesterday=$(date -d "$1 days ago" +%m/%d/%y)
  today=$(date -d "$1 days ago + 1 day" +%m/%d/%y)
fi

echo filename: $yesterdayfile
echo start: $yesterday
echo end: $today

# 1st qtr
sacct --allusers --parsable2 --noheader --allocations --clusters marcc --format jobid,jobidraw,cluster,partition,account,group,gid,user,uid,submit,eligible,start,end,elapsed,exitcode,state,nnodes,ncpus,reqcpus,reqmem,reqgres,reqtres,timelimit,nodelist,jobname --state CANCELLED,COMPLETED,FAILED,NODE_FAIL,PREEMPTED,TIMEOUT --starttime $yesterday-00:00 --endtime $yesterday-6:00 > $HOME/slurmlogs/sacct_daily.${yesterdayfile}a

# 2nd qtr
sacct --allusers --parsable2 --noheader --allocations --clusters marcc --format jobid,jobidraw,cluster,partition,account,group,gid,user,uid,submit,eligible,start,end,elapsed,exitcode,state,nnodes,ncpus,reqcpus,reqmem,reqgres,reqtres,timelimit,nodelist,jobname --state CANCELLED,COMPLETED,FAILED,NODE_FAIL,PREEMPTED,TIMEOUT --starttime $yesterday-6:00 --endtime $yesterday-12:00 > $HOME/slurmlogs/sacct_daily.${yesterdayfile}b

# 3rd qtr
sacct --allusers --parsable2 --noheader --allocations --clusters marcc --format jobid,jobidraw,cluster,partition,account,group,gid,user,uid,submit,eligible,start,end,elapsed,exitcode,state,nnodes,ncpus,reqcpus,reqmem,reqgres,reqtres,timelimit,nodelist,jobname --state CANCELLED,COMPLETED,FAILED,NODE_FAIL,PREEMPTED,TIMEOUT --starttime $yesterday-12:00 --endtime $yesterday-18:00 > $HOME/slurmlogs/sacct_daily.${yesterdayfile}c

# 4th qtr
sacct --allusers --parsable2 --noheader --allocations --clusters marcc --format jobid,jobidraw,cluster,partition,account,group,gid,user,uid,submit,eligible,start,end,elapsed,exitcode,state,nnodes,ncpus,reqcpus,reqmem,reqgres,reqtres,timelimit,nodelist,jobname --state CANCELLED,COMPLETED,FAILED,NODE_FAIL,PREEMPTED,TIMEOUT --starttime $yesterday-18:00 --endtime $today > $HOME/slurmlogs/sacct_daily.${yesterdayfile}d
