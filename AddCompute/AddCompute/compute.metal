//
//  compute.metal
//  AddCompute
//
//  Created by Alvin Tu on 4/6/21.
//

#include <metal_stdlib>
using namespace metal;

kernel void addition_compute_function(constant float *arr1         [[buffer(0)]],
                                        constant float *arr2         [[buffer(1)]],
                                        device  float *resultArray    [[buffer(2)]],
                                                uint index[[thread_position_in_grid]] ){
    resultArray[index] = arr1[index]+ arr2[index];
}


//how does the cpu communicate with the gpu?

//they act as separate sources, inbetween them, there is a
//shared cpu/gpu memory state
//with buffer(0)
//     buffer(1)

// cpu setBuffer(arr1Buffer, offset: 0, index: 0 --------> shared CPU/GPU Memory State <------ GPU [[buffer(0)]]
//                                                                  buffer(0)

// cpu setBuffer(arrBuffer, offset: 0, index: 1 --------> shared CPU/GPU Memory State <------ GPU [[buffer(1)]]
//                                                                  buffer(1)
