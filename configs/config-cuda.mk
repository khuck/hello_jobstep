NVHPC_CUDA_HOME=/packages/nvhpc/22.11_cuda11.8/Linux_x86_64/22.11/cuda/11.8
#CUDA_VISIBLE_DEVICES=0
NVCC      = mpicxx
NVFLAGS   = -gpu=cc80 -g -fopenmp -Mcuda
INCLUDES  =
LIBRARIES = -L$(NVHPC_CUDA_HOME)/lib64 -lcudart -lcuda -Mcuda

