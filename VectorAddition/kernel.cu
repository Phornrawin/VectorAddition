#include <cuda.h>
#include <stdio.h>
#include <math.h>

__global__ void vectorAdd(int *d_a, int *d_b, int *d_c, int n) {
	int i = threadIdx.x + blockIdx.x * blockDim.x;
	int b = blockIdx.x ;

	if (i >= n) {
		return;
	}
	d_c[i] = d_a[i] + d_b[i];

	/*for (int i = 0; i < n; i++) {
		d_c[i] = d_a[i] + d_b[i];
		printf("C[%d] = %d from thread = %d\n", i, d_c[i], threadIdx.x);
	}*/

	printf("C[%d] = %d thread = %d block = %d \n", i, d_c[i], i, b);
}
int main() {
	const int N = 3000;
	
	int h_a[N];
	int h_b[N];

	int h_c[N];

	for (int i = 0; i < N; i++) {
		h_a[i] = i;
	}

	for (int i = 0; i < N; i++) {
		h_b[i] = N-i;
	}

	//Part1
	int *d_a, *d_b, *d_c;
	cudaMalloc((void**) &d_a, N * sizeof(int));
	cudaMalloc((void**) &d_b, N * sizeof(int));
	cudaMalloc((void**) &d_c, N * sizeof(int));

	cudaMemcpy(d_a, &h_a, N * sizeof(int), cudaMemcpyHostToDevice);
	cudaMemcpy(d_b, &h_b, N * sizeof(int), cudaMemcpyHostToDevice);

	//define DUDA Timer
	cudaEvent_t start;
	cudaEvent_t stop;
	cudaEventCreate(&start);
	cudaEventCreate(&stop);

	//start Cuda timer
	cudaEventRecord(start, 0);

	//Part2
	int blockNumber = ceil(N / 1024);
	vectorAdd<<<blockNumber,1024>>>(d_a, d_b, d_c, N);
	
	//stop Cuda timer
	cudaEventRecord(stop, 0);
	cudaEventSynchronize(stop);

	//compute elapsed time
	float time;
	cudaEventElapsedTime(&time, start, stop);

	//Part3
	cudaMemcpy(&h_c, d_c, N * sizeof(int), cudaMemcpyDeviceToHost);

	cudaFree(d_a);
	cudaFree(d_b);
	cudaFree(d_c);

	//report time in kernel
	printf("Time in kernel = %f ms \n", time);

	return 0;
}