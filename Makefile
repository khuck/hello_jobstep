CXX      = mpicxx
CFLAGS   = -g -fopenmp -std=c++11
LDFLAGS   = -g -fopenmp -std=c++11
INCLUDES  = -pthread
LIBRARIES = -pthread -L/opt/rocm-5.2.0/lib -lamdhip64 -L/opt/cray/pe/mpich/8.1.23/gtl/lib -lmpi_gtl_hsa

hello_jobstep: hello_jobstep.o hello_openmp.o hello_hip.o hello_pthreads.o
	${CXX} ${LDFLAGS} hello_jobstep.o hello_hip.o hello_openmp.o hello_pthreads.o -o hello_jobstep ${LIBRARIES}

hello_jobstep.o: hello_jobstep.cpp
	${CXX} ${CFLAGS} ${INCLUDES} -c hello_jobstep.cpp

hello_hip.o: hello_hip.cpp
	${CXX} ${CFLAGS} ${INCLUDES} -c hello_hip.cpp

hello_openmp.o: hello_openmp.cpp
	${CXX} ${CFLAGS} ${INCLUDES} -c hello_openmp.cpp

hello_pthreads.o: hello_pthreads.cpp
	${CXX} ${CFLAGS} ${INCLUDES} -c hello_pthreads.cpp

.PHONY: clean

clean:
	rm -f hello_jobstep *.o

test:
	./test.sh
