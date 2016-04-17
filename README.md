# qsub.sh
Simple tool using GNU parallel to run PBS jobs on a single machine.

## Usage

The idea of this script is to provide a simple replacement for qsub cluster exection, taking the same arguments as standard PBS/SGE submissions.

###Simple example with a dependency
```bash
$ job_align = $( qsub.sh -o align.log -e align.stderr.log job_align & echo $! )
$ qsub.sh -v var1=xyz -o translate.log -e translate.stderr.log -h $job_align job_translate

```
