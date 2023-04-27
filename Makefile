CXX      = mpicxx
CFLAGS   = -g -fopenmp -std=c++11
LDFLAGS   = -g -fopenmp -std=c++11
INCLUDES  = -pthread
LIBRARIES = -pthread
GPU_OBJ = hello_nogpu.o # hello_hip.o hello_cuda.o hello_nogpu.o

hello_jobstep: hello_jobstep.o hello_openmp.o ${GPU_OBJ} hello_pthreads.o
	${CXX} ${LDFLAGS} hello_jobstep.o ${GPU_OBJ} hello_openmp.o hello_pthreads.o -o hello_jobstep ${LIBRARIES}

hello_jobstep.o: hello_jobstep.cpp
	${CXX} ${CFLAGS} ${INCLUDES} -c hello_jobstep.cpp

hello_nogpu.o: hello_nogpu.cpp
	${CXX} ${CFLAGS} ${INCLUDES} -c hello_nogpu.cpp

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
