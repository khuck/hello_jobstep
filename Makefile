NVHPC_CUDA_HOME=/packages/nvhpc/22.11_cuda11.8/Linux_x86_64/22.11/cuda/11.8
#CUDA_VISIBLE_DEVICES=0
NVCC      = mpicxx
NVFLAGS   = -gpu=cc80 -g -fopenmp -Mcuda
INCLUDES  =
LIBRARIES = -L$(NVHPC_CUDA_HOME)/lib64 -lcudart -lcuda -Mcuda

hello_jobstep: hello_jobstep.o
	${NVCC} hello_jobstep.o -o hello_jobstep ${LIBRARIES}

hello_jobstep.o: hello_jobstep.cu
	${NVCC} ${NVFLAGS} ${INCLUDES} -c hello_jobstep.cu

.PHONY: clean

clean:
	rm -f hello_jobstep *.o

test:
	./test.sh
