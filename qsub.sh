#!/bin/bash

#Input variables passed to qsub
vars=""

#Support for array jobs:
array_from=""
array_to=""

#Jobs may wait for other jobs
holds=""

#Standard stdout and stderr files
out="stdout.log"
err="stderr.log"

#Flags for GNU parallel
PARALLEL_FLAGS=""

while getopts "l:t:v:N:h:o:e:j:" opt; do
  case $opt in
    l) echo Ignoring l;;
    N) echo Ignoring N;;
    h) holds=${OPTARG//:/ };;
    o) out=$OPTARG;;
    j) PARALLEL_FLAGS="-j $OPTARG";;
    e) err=$OPTARG;;
    t)
      array_from=$(echo $OPTARG | sed 's/[-].*//')
      array_to=$(echo $OPTARG | sed 's/^.*[-]//')
      echo "This is an array job, from: $array_from - $array_to"
      ;;
    v)
      echo "Variables:" $OPTARG
      vars=${OPTARG//,/ }
      ;;
  esac
done

if [[ -d $out ]]; then
  out="$out/stdout.log"
fi
if [[ -d $err ]]; then
  err="$err/stderr.log"
fi

shift $((OPTIND-1))


##################################
# Wait for previous jobs to finish
echo "Holds: $holds"
if [[ $holds ]]; then
  still_running="yes"
else
  still_running=""
fi

while [[ $still_running ]]; do
  sleep 1m
  still_running=""
  for p in $holds; do
    if [[ ( -d /proc/$p ) && ( -z `grep zombie /proc/$p/status` ) ]]; then
    	still_running="yes"
    fi
  done
done
##############################

if [[ $array_from ]]; then
  echo "Running parallel job..."
  seq $array_from $array_to | parallel $PARALLEL_FLAGS "PBS_ARRAYID={} $vars bash $1 2>> $err >> $out"
else 
  echo "Running linear job.."
  eval $vars bash $1 2>> $err >> $out
fi
