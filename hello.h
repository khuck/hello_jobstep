#include <set>

int getgpu(const int rank, const int section, const char * name);
int getopenmp(const int rank, const int section, const int ncpus, std::set<long>& tids);
int getpthreads(const int rank, const int section, const int ncpus, std::set<long>& tids);

