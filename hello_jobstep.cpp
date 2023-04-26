/**********************************************************
"Hello World"-type program to test different srun layouts.

Written by Tom Papatheodore
**********************************************************/

#ifndef _GNU_SOURCE
#define _GNU_SOURCE             /* See feature_test_macros(7) */
#endif
#define _XOPEN_SOURCE 700
#include <sched.h>

#include <stdlib.h>
#include <stdio.h>
#include <iostream>
#include <set>
#include <iomanip>
#include <iomanip>
#include <string.h>
#include <mpi.h>
#include <omp.h>
#include <hip/hip_runtime.h>

#include <sys/types.h>
#include <dirent.h>
#include <unistd.h>
#include <sys/syscall.h>
#define gettid() syscall(SYS_gettid)

// Macro for checking errors in GPU API calls
#define gpuErrorCheck(call)                                                                  \
do{                                                                                          \
    hipError_t gpuErr = call;                                                               \
    if(hipSuccess != gpuErr){                                                               \
        printf("GPU Error - %s:%d: '%s'\n", __FILE__, __LINE__, hipGetErrorString(gpuErr)); \
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

    // If HIP_VISIBLE_DEVICES is set, capture visible GPUs
    const char* gpu_id_list;
    const char* gpu_visible_devices = getenv("HIP_VISIBLE_DEVICES");
    if(gpu_visible_devices == NULL){
       	gpu_id_list = "N/A";
    }
    else{
       	gpu_id_list = gpu_visible_devices;
    }

	// Find how many GPUs runtime says are available
	int num_devices = 0;
    gpuErrorCheck( hipGetDeviceCount(&num_devices) );

	int hwthread;
	int thread_id = 0;
    int ncpus = std::thread::hardware_concurrency();

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

			gpuErrorCheck( hipSetDevice(i) );

			// Get the PCIBusId for each GPU and use it to query for UUID
			gpuErrorCheck( hipDeviceGetPCIBusId(busid, 64, i) );

			// Concatenate per-MPIrank GPU info into strings for print
            if(i > 0) rt_gpu_id_list.append(",");
            rt_gpu_id_list.append(std::to_string(i));

            std::string temp_busid(busid);

            if(i > 0) busid_list.append(",");
//            busid_list.append(temp_busid.substr(8,2));
            busid_list.append(temp_busid);

		}
        std::set<long> tids;

		#pragma omp parallel default(shared) private(hwthread, thread_id)
		{
            auto nthreads = omp_get_num_threads();
            //#pragma omp critical
            #pragma omp for ordered
            for (int i = 0 ; i < nthreads ; i++)
            {
                #pragma omp ordered
                {
			    thread_id = omp_get_thread_num();
			    hwthread = sched_getcpu();
            /*
                cpu_set_t *mask;
                mask = CPU_ALLOC(ncpus);
                CPU_ZERO(mask);
                auto msize = CPU_ALLOC_SIZE(ncpus);
                int retval = sched_getaffinity(0, msize, mask);
                auto nhwthr = CPU_COUNT_S(msize, mask);
                CPU_FREE(mask);
                */
                cpu_set_t mask;
                CPU_ZERO(&mask);
                auto msize = sizeof(mask);
                sched_getaffinity(0, msize, &mask);
                int nhwthr = CPU_COUNT(&mask);
                std::string tmpstr;
                for (int i = 0; i < ncpus ; i++) {
                    // which hwthreads are in the set?
                    if (CPU_ISSET(i, &mask)) {
                        tmpstr = tmpstr + std::to_string(i) + ",";
                    }
                }
                auto lwp = gettid();
                tids.insert(lwp);

                printf("MPI %03d - OMP %03d - HWT %03d - LWP %06ld - #HWT %03d - Set %s - Node %s - RT_GPU_ID %s - GPU_ID %s - Bus_ID %s\n",
                    rank, thread_id, hwthread, lwp, nhwthr, tmpstr.c_str(), name, rt_gpu_id_list.c_str(), gpu_id_list, busid_list.c_str());
                }
           }
		}

        std::string tmpstr;
        DIR *dp;
        struct dirent *ep;
        dp = opendir ("/proc/self/task");
        if (dp != NULL)
        {
            while ((ep = readdir (dp)) != NULL) {
                if (strncmp(ep->d_name, ".", 1) == 0) continue;
                tmpstr = tmpstr + ep->d_name + ", ";
                long lwp = atol(ep->d_name);
                if (!tids.count(lwp)) {
                    cpu_set_t mask;
                    CPU_ZERO(&mask);
                    auto msize = sizeof(mask);
                    sched_getaffinity(lwp, msize, &mask);
                    int nhwthr = CPU_COUNT(&mask);
                    std::string tmpstr2;
                    for (int i = 0; i < ncpus ; i++) {
                        // which hwthreads are in the set?
                        if (CPU_ISSET(i, &mask)) {
                            tmpstr2 = tmpstr2 + std::to_string(i) + ",";
                        }
                    }
                    printf("MPI %03d - LWP %06ld - #HWT %03d - Set %s \n",
                        rank, lwp, nhwthr, tmpstr2.c_str());
                }
            }
            (void) closedir (dp);
        }
        printf("MPI %03d - LWP - %s\n", rank, tmpstr.c_str());
	}

	MPI_Finalize();

	return 0;
}
