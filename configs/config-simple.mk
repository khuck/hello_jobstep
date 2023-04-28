CXX      = mpicxx
CFLAGS   = -g -fopenmp -std=c++11
LDFLAGS   = -g -fopenmp -std=c++11
INCLUDES  = -pthread
LIBRARIES = -pthread
GPU_OBJ = hello_nogpu.o # hello_hip.o hello_cuda.o hello_nogpu.o

