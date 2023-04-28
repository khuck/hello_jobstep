
CXX      = hipcc
CFLAGS   = -g -fopenmp -std=c++11
LDFLAGS   = -g -fopenmp -std=c++11
INCLUDES  = -I/usr/local/packages/openmpi/4.1.1-rocm5.2.0/include -pthread
LIBRARIES = -pthread -Wl,-rpath -Wl,/usr/local/packages/openmpi/4.1.1-rocm5.2.0/lib -Wl,--enable-new-dtags -L/usr/local/packages/openmpi/4.1.1-rocm5.2.0/lib -lmpi_cxx -lmpi
GPU_OBJ = hello_hip.o # hello_hip.o hello_cuda.o hello_nogpu.o

