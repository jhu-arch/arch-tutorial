#!/bin/bash
# -*- coding: utf-8 -*-
# SLURM job script for run RStudio into Singularity container
# The Advanced Research Computing at Hopkins (ARCH)
# Ricardo S Jacomini < rdesouz4 @ jhu.edu >
# Date: May, 5 2022

rsync -rav --delete rdesouz4@login.marcc.jhu.edu:/home-0/rdesouz4/XDMoD/slurmlogs /root/slurmlogs/log_from_marcc_daily
