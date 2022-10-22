#!/bin/bash

qsub -w e -N eh -pe smp 8 -wd /hades/psivakumar/cohorts/macrogen_eh -o /hades/psivakumar/cohorts/macrogen_eh/macrogen_eh_pileup.log -e /hades/psivakumar/cohorts/macrogen_eh/macrogen_eh_pileup.err macrogen_eh_pileup.sh
