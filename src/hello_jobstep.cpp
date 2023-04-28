/**********************************************************
"Hello World"-type program to test different srun layouts.

Written by Tom Papatheodore
**********************************************************/

#include <stdlib.h>
#include <stdio.h>
#include <iostream>
#include <thread>
#include <set>
#include <mpi.h>
#include "hello.h"

int main(int argc, char *argv[]){

    int size;
    int rank;
    char name[MPI_MAX_PROCESSOR_NAME];
    int resultlength;

    // get mpi info
    MPI_Init(&argc, &argv);
    MPI_Comm_size(MPI_COMM_WORLD, &size);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Get_processor_name(name, &resultlength);

    int section = 0;
    getgpu(rank, section++, name);
    std::set<long> tids;
    int ncpus = std::thread::hardware_concurrency();
    getopenmp(rank, section++, ncpus, tids);
    getpthreads(rank, section++, ncpus, tids);

    MPI_Finalize();

    return 0;
}
