//
//  main.swift
//  AddCompute
//
//  Created by Alvin Tu on 4/6/21.
//
import MetalKit

let count: Int = 3000000

var array1 = getRandomArray()
var array2 = getRandomArray()

computeWay(arr1:array1,arr2:array2)
basicForLoopWay(arr1:array1, arr2:array2)

func computeWay(arr1:[Float],arr2:[Float]) {
    
    let startTime = CFAbsoluteTimeGetCurrent()
    
    let device = MTLCreateSystemDefaultDevice()
    
    let commandQueue = device?.makeCommandQueue()
    
    let gpuFunctionLibrary = device?.makeDefaultLibrary()
    
    let additionGPUFunction = gpuFunctionLibrary?.makeFunction(name:"addition_compute_function")
    
    var additionComputePipelineState: MTLComputePipelineState!
    do {
        additionComputePipelineState = try device?.makeComputePipelineState(function: additionGPUFunction!)
    } catch {
        print(error)
    }
    print()
    print("Compute Way")
    
    let arr1Buff = device?.makeBuffer(bytes: arr1, length: MemoryLayout<Float>.size * count, options: .storageModeShared)
    
    let arr2Buff = device?.makeBuffer(bytes: arr2, length: MemoryLayout<Float>.size * count, options: .storageModeShared)
    
    let resultBuff = device?.makeBuffer(length: MemoryLayout<Float>.size * count, options: .storageModeShared)
    
    //Create a buffer to be sent to the command queue
    let commandBuffer = commandQueue?.makeCommandBuffer()
    
    //create an encoder to set values on the compute function
    let commandEncoder = commandBuffer?.makeComputeCommandEncoder()
    commandEncoder?.setComputePipelineState(additionComputePipelineState)
    
    //set parameters of the gpu function
    commandEncoder?.setBuffer(arr1Buff, offset: 0, index: 0)
    commandEncoder?.setBuffer(arr2Buff, offset: 0, index: 1)
    commandEncoder?.setBuffer(resultBuff, offset: 0, index: 2)
    
    //figure out how many threads we need to use for our operation
    let threadsPerGrid = MTLSize(width: count, height: 1, depth: 1)
    let maxThreadsPerThreadGroup = additionComputePipelineState.maxTotalThreadsPerThreadgroup
    let threadsPerThreadGroup = MTLSize(width: maxThreadsPerThreadGroup, height: 1, depth: 1)
    commandEncoder?.dispatchThreads(threadsPerGrid,
                                    threadsPerThreadgroup: threadsPerThreadGroup)
    //tell encoder that it is done encoding. now, we sent this off to the gpu
    commandEncoder?.endEncoding()
    //push this command to the command queue for processing
    commandBuffer?.commit()
//wait until the gpu function completes before working with any of the data
    commandBuffer?.waitUntilCompleted()
    //waitUntilCompleted is actually considered bad practice because it prevents cpu-gpu parallelism -
    //use     commandBuffer?.addCompletedHandler() instead

    
    //get the pointer to the beginning of the data
    var resultBufferPointer = resultBuff?.contents().bindMemory(to: Float.self, capacity: MemoryLayout<Float>.size * count)
    
    //print out all of our newly added together array
    for i in 0..<3 {
        print("\(arr1[i]) + \(arr2[i]) = \(Float(resultBufferPointer!.pointee) as Any)")
        resultBufferPointer = resultBufferPointer?.advanced(by: 1)
    }
    //print out elapsedDate
    let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
    print("Time elapsed \(String(format: "%.05f", timeElapsed)) seconds")
    print()
    
    
}

func basicForLoopWay(arr1: [Float], arr2: [Float]) {
    print("Basic For Loop Way")
    
    let startTime = CFAbsoluteTimeGetCurrent()
    var result = [Float].init(repeating: 0.0, count: count)
    
    for i in 0..<count {
        result[i] = arr1[i] + arr2[i]
    }
    
    for i in 0..<3 {
        print("\([arr1[i]]) + \([arr2[i]])) = \(result[i])")
    }
    
    
    let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
    print("Time elapsed \(String(format: "%.05f", timeElapsed)) seconds")
}


func getRandomArray()->[Float] {
    var result = [Float].init(repeating: 0.0, count: count)
    for i in 0..<count {
        result[i] = Float(arc4random_uniform(10))
    }
    return result
}
