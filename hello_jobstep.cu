/**********************************************************
"Hello World"-type program to test different srun layouts.

Written by Tom Papatheodore
**********************************************************/

#include <stdlib.h>
#include <stdio.h>
#include <iostream>
#include <iomanip>
#include <iomanip>
#include <string.h>
#include <mpi.h>
#include <sched.h>
#include <omp.h>

// Macro for checking errors in GPU API calls
#define gpuErrorCheck(call)                                                                  \
do{                                                                                          \
    cudaError_t gpuErr = call;                                                               \
    if(cudaSuccess != gpuErr){                                                               \
        printf("GPU Error - %s:%d: '%s'\n", __FILE__, __LINE__, cudaGetErrorString(gpuErr)); \
        exit(0);                                                                             \
    }                                                                                        \
}while(0)

int main(int argc, char *argv[]){

	MPI_Init(&argc, &argv);

	int size;
	MPI_Comm_size(MPI_COMM_WORLD, &size);

	int rank;
	MPI_Comm_rank(MPI_COMM_WORLD, &rank);

	char name[MPI_MAX_PROCESSOR_NAME];
	int resultlength;
	MPI_Get_processor_name(name, &resultlength);

    // If CUDA_VISIBLE_DEVICES is set, capture visible GPUs
    const char* gpu_id_list; 
    const char* gpu_visible_devices = getenv("CUDA_VISIBLE_DEVICES");
    if(gpu_visible_devices == NULL){
       	gpu_id_list = "N/A";
    }
    else{
       	gpu_id_list = gpu_visible_devices;
    }

	// Find how many GPUs runtime says are available
	int num_devices = 0;
    gpuErrorCheck( cudaGetDeviceCount(&num_devices) );

	int hwthread;
	int thread_id = 0;

	if(num_devices == 0){
		#pragma omp parallel default(shared) private(hwthread, thread_id)
		{
			thread_id = omp_get_thread_num();
			hwthread = sched_getcpu();

            printf("MPI %03d - OMP %03d - HWT %03d - Node %s\n", 
                    rank, thread_id, hwthread, name);
		}
	}
	else{

		char busid[64];

        std::string busid_list = "";
        std::string rt_gpu_id_list = "";

		// Loop over the GPUs available to each MPI rank
		for(int i=0; i<num_devices; i++){

			gpuErrorCheck( cudaSetDevice(i) );

			// Get the PCIBusId for each GPU and use it to query for UUID
			gpuErrorCheck( cudaDeviceGetPCIBusId(busid, 64, i) );

			// Concatenate per-MPIrank GPU info into strings for print
            if(i > 0) rt_gpu_id_list.append(",");
            rt_gpu_id_list.append(std::to_string(i));

            std::string temp_busid(busid);

            if(i > 0) busid_list.append(",");
//            busid_list.append(temp_busid.substr(8,2));
            busid_list.append(temp_busid);

		}

		#pragma omp parallel default(shared) private(hwthread, thread_id)
		{
            #pragma omp critical
            {
			thread_id = omp_get_thread_num();
			hwthread = sched_getcpu();

            printf("MPI %03d - OMP %03d - HWT %03d - Node %s - RT_GPU_ID %s - GPU_ID %s - Bus_ID %s\n",
                    rank, thread_id, hwthread, name, rt_gpu_id_list.c_str(), gpu_id_list, busid_list.c_str());
           }
		}
	}

	MPI_Finalize();

	return 0;
}
