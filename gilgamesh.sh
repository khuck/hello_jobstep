#!/bin/bash

export NVHPC_CUDA_HOME=/packages/nvhpc/22.11_cuda11.8/Linux_x86_64/22.11/cuda/11.8
export CUDA_VISIBLE_DEVICES=0
export ROCR_VISIBLE_DEVICES=0,1

let PROCS=16
let CORES=48/${PROCS}
#let PROCS=1
#REPORT="--report-bindings"
MCA="-mca btl_base_warn_component_unused 0"

doit() {
    export OMP_PROC_BIND=spread
    #export OMP_DISPLAY_ENV=1
    set -x
    export OMP_NUM_THREADS=${THREADS}
    mpirun -n ${PROCS} ${BIND} ${MCA} ${REPORT} \
    /mnt/beegfs/users/khuck/src/apex/install_gilgamesh_5.2.0/bin/apex_exec \
    --apex:pthread --apex:mpi --apex:ompt --apex:status --apex:monitor_cpu \
    ./hello_jobstep
    set +x
}

# Hyperthreading

hyper() {
    let THREADS=${CORES}*2
    BIND="--bind-to hwthread --cpus-per-proc ${THREADS}"
    #BIND="--bind-to slot --map-by unit:PE=6"
    #BIND="--map-by NUMA:PE=6"
    export OMP_PLACES=threads
    echo "Hyperthreading"
    doit
}

# No hyperthreading

nohyper() {
    let THREADS=${CORES}
    BIND="--bind-to core --cpus-per-proc ${THREADS}"
    #BIND="--bind-to core --map-by core"
    export OMP_PLACES=cores
    echo "No Hyperthreading"
    doit
}

# Socket

socket() {
    let THREADS=${CORES}
    BIND="--bind-to core --cpus-per-proc ${THREADS}"
    #BIND="--bind-to core --map-by core"
    export OMP_PLACES=sockets
    echo "Socket"
    doit
}

hyper
nohyper
socket

