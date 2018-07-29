#include <stdio.h>
#include <math.h>

__global__ void add(float *A, float *B, float *C, int N)
{
    int thread_index = blockDim.x * blockIdx.x + threadIdx.x;

    if (thread_index < N)
        C[thread_index] = A[thread_index] + B[thread_index];
}

void generate_floats(float *A, int N)
{
    for (int i = 0; i < N; ++i)
        A[i] = sin(i) + cos(i);
}

int main()
{
    printf("\n\nProgram to perform Vector Addition in CUDA\n\n");
    int N = 2048; // Number of elements in the array

    float *A, *B, *C;
    float host_A[N], host_B[N], host_C[N];

    // generate random floating numbers for input
    printf("\nGenerating %d floating-point numbers for the input arrays....\n", N);
    generate_floats(host_A, N);
    generate_floats(host_B, N);

    printf("\nAllocating memory on the GPU...\n\n");
    // allocate space on device
    cudaMalloc((void **)&A, N * sizeof(float));
    cudaMalloc((void **)&B, N * sizeof(float));
    cudaMalloc((void **)&C, N * sizeof(float));

    // memory transfer from host to device
    printf("\nTransferring data from host to device for computations...\n\n");

    cudaMemcpy(A, host_A, N * sizeof(float), cudaMemcpyHostToDevice);
    cudaMemcpy(B, host_B, N * sizeof(float), cudaMemcpyHostToDevice);

    // dimensions of thread block + kernel launch
    int blockDim = 1024;

    int gridDim = ceil((float)(N) / 1024);

    printf("\n\nCalling the kernel with %d Blocks and %d threads in each block\n", gridDim, blockDim);

    add<<<gridDim, blockDim>>>(A, B, C, N);

    // copy back to host
    printf("\n\nCalculation completed on the GPU. Fetching the answer back from the GPU's global memory\n");
    cudaMemcpy(host_C, C, N * sizeof(float), cudaMemcpyDeviceToHost);

    // free the malloc'ed memory
    printf("\n\nFree'ing the malloc'ed memory on the GPU\n");
    cudaFree(A);
    cudaFree(B);
    cudaFree(C);

    return 0;
}