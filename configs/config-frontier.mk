CXX      = mpicxx
CFLAGS   = -g -fopenmp -std=c++11
LDFLAGS   = -g -fopenmp -std=c++11
INCLUDES  = -pthread
LIBRARIES = -pthread -L/opt/rocm-5.2.0/lib -lamdhip64 -L/opt/cray/pe/mpich/8.1.23/gtl/lib -lmpi_gtl_hsa

