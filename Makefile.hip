CXX      = hipcc
CFLAGS   = -g -fopenmp
LDFLAGS   = -g -fopenmp
INCLUDES  = -I/usr/local/packages/openmpi/4.1.1-rocm5.2.0/include -pthread
LIBRARIES = -pthread -Wl,-rpath -Wl,/usr/local/packages/openmpi/4.1.1-rocm5.2.0/lib -Wl,--enable-new-dtags -L/usr/local/packages/openmpi/4.1.1-rocm5.2.0/lib -lmpi_cxx -lmpi

hello_jobstep: hello_jobstep.o
	${CXX} ${LDFLAGS} hello_jobstep.o -o hello_jobstep ${LIBRARIES}

hello_jobstep.o: hello_jobstep.cpp
	${CXX} ${CFLAGS} ${INCLUDES} -c hello_jobstep.cpp

.PHONY: clean

clean:
	rm -f hello_jobstep *.o

test:
	./test.sh
