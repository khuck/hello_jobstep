NVHPC_CUDA_HOME=/packages/nvhpc/22.11_cuda11.8/Linux_x86_64/22.11/cuda/11.8
CXX       = mpicxx
CFLAGS    = -g -fopenmp -std=c++11 -gpu=cc80 -g -fopenmp -Mcuda
LDFLAGS    = -g -fopenmp -std=c++11 -gpu=cc80 -g -fopenmp -Mcuda
NVFLAGS   = -gpu=cc80 -g -fopenmp -Mcuda
INCLUDES  =
LIBRARIES = -L$(NVHPC_CUDA_HOME)/lib64 -lcudart -lcuda -Mcuda
GPU_OBJ = hello_cuda.o # hello_hip.o hello_cuda.o hello_nogpu.o

