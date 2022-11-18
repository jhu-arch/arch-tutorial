#!/bin/bash
xdmod-shredder -r marcc -f slurm -i $HOME/slurmlogs2/sacct_daily.$(date --date="yesterday" +%Y%m%d)a
xdmod-ingestor
xdmod-shredder -r marcc -f slurm -i $HOME/slurmlogs2/sacct_daily.$(date --date="yesterday" +%Y%m%d)b
xdmod-ingestor
xdmod-shredder -r marcc -f slurm -i $HOME/slurmlogs2/sacct_daily.$(date --date="yesterday" +%Y%m%d)c
xdmod-ingestor
xdmod-shredder -r marcc -f slurm -i $HOME/slurmlogs2/sacct_daily.$(date --date="yesterday" +%Y%m%d)d
xdmod-ingestor
