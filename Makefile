# Change this to the appropriate platform
include configs/config-hip.mk

# No need to change below this...

hello_jobstep: obj/hello_jobstep.o obj/hello_openmp.o obj/${GPU_OBJ} obj/hello_pthreads.o
	${CXX} ${LDFLAGS} obj/hello_jobstep.o obj/${GPU_OBJ} obj/hello_openmp.o obj/hello_pthreads.o -o hello_jobstep ${LIBRARIES}

obj/hello_jobstep.o: src/hello_jobstep.cpp
	${CXX} ${CFLAGS} ${INCLUDES} -c src/hello_jobstep.cpp -o obj/hello_jobstep.o

obj/hello_nogpu.o: src/hello_nogpu.cpp
	${CXX} ${CFLAGS} ${INCLUDES} -c src/hello_nogpu.cpp -o obj/hello_nogpu.o

obj/hello_hip.o: src/hello_hip.cpp
	${CXX} ${CFLAGS} ${INCLUDES} -c src/hello_hip.cpp -o obj/hello_hip.o

obj/hello_openmp.o: src/hello_openmp.cpp
	${CXX} ${CFLAGS} ${INCLUDES} -c src/hello_openmp.cpp -o obj/hello_openmp.o

obj/hello_pthreads.o: src/hello_pthreads.cpp
	${CXX} ${CFLAGS} ${INCLUDES} -c src/hello_pthreads.cpp -o obj/hello_pthreads.o

.PHONY: clean

clean:
	rm -f hello_jobstep obj/*.o

test:
	./test.sh
