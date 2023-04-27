CXX      = hipcc
CFLAGS   = -g -fopenmp -std=c++11
LDFLAGS   = -g -fopenmp -std=c++11
INCLUDES  = -I/usr/local/packages/openmpi/4.1.1-rocm5.2.0/include -pthread
LIBRARIES = -pthread -Wl,-rpath -Wl,/usr/local/packages/openmpi/4.1.1-rocm5.2.0/lib -Wl,--enable-new-dtags -L/usr/local/packages/openmpi/4.1.1-rocm5.2.0/lib -lmpi_cxx -lmpi

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
