#!/bin/bash

export NVHPC_CUDA_HOME=/packages/nvhpc/22.11_cuda11.8/Linux_x86_64/22.11/cuda/11.8
export CUDA_VISIBLE_DEVICES=0

let PROCS=8
let CORES=48/${PROCS}
#REPORT="--report-bindings"
MCA="-mca btl_base_warn_component_unused 0"

doit() {
    export OMP_PROC_BIND=spread
    export OMP_DISPLAY_ENV=1
    set -x
    export OMP_NUM_THREADS=${THREADS}
    mpirun -n ${PROCS} ${BIND} ${MCA} ${REPORT} ./hello_jobstep | grep -e "MPI 000" -e "OMP_"
    set +x
}

# Hyperthreading

hyper() {
    let THREADS=${CORES}*2
    BIND="--bind-to hwthread --cpus-per-proc ${THREADS}"
    #BIND="--bind-to slot --map-by unit:PE=6"
    #BIND="--map-by NUMA:PE=6"
    export OMP_PLACES=thread
    echo "Hyperthreading"
    doit
}

# No hyperthreading

nohyper() {
    let THREADS=${CORES}
    BIND="--bind-to core --cpus-per-proc ${THREADS}"
    #BIND="--bind-to core --map-by core"
    export OMP_PLACES=core
    echo "No Hyperthreading"
    doit
}

nohyper

