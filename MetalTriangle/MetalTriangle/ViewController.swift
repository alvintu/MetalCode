//
//  ViewController.swift
//  MetalTriangle
//
//  Created by Alvin Tu on 4/6/21.
//


import UIKit
import Metal

class ViewController: UIViewController {
  var device: MTLDevice!
  var metalLayer: CAMetalLayer!
  var vertexBuffer: MTLBuffer!
  let vertexData: [Float] = [
    0.0, 1.0, 0.00,
    -1.0, -1.0, 0.0,
    1.0, -1.0, 0.0
  ]
  var pipelineState: MTLRenderPipelineState!
  var commandQueue: MTLCommandQueue!
  var timer: CADisplayLink!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    device = MTLCreateSystemDefaultDevice()
    
    metalLayer = CAMetalLayer()//create new metal layer
    metalLayer.device = device //specify device layer should use
    metalLayer.pixelFormat = .bgra8Unorm //8 bytes blue green red alpha with normalized values
    metalLayer.framebufferOnly = true //apple recommendation for performance reasons unless :
    //1) you need to sample from textures generated for this layer
    //2) if you need to enable compute kernels on the layer drawable texture
    metalLayer.frame = view.layer.frame //set frame of layer to frame of view
    view.layer.addSublayer(metalLayer) //add sublayer
    
    let dataSize = vertexData.count * MemoryLayout.size(ofValue: vertexData[0]) //get the size of the vertex data in bytes, by multiplying the size of the first element by the count of elements in array
    vertexBuffer = device.makeBuffer(bytes: vertexData, length: dataSize, options: [])
    // create new buffer on the GPU, passing in data from the CPU. pass an empty array for default configuration
    let defaultLibrary = device.makeDefaultLibrary()
    let fragmentProgram = defaultLibrary?.makeFunction(name:"basic_fragment")
    let vertexProgram = defaultLibrary?.makeFunction(name: "basic_vertex")
    
    let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
    pipelineStateDescriptor.vertexFunction = vertexProgram
    pipelineStateDescriptor.fragmentFunction = fragmentProgram
    pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
    
    pipelineState = try! device.makeRenderPipelineState(descriptor:pipelineStateDescriptor)
    
    commandQueue = device.makeCommandQueue()
    
    timer = CADisplayLink(target: self, selector: #selector(gameLoop))
    timer.add(to: RunLoop.main, forMode: .default)
    
    
  }
  func render() {
    guard let drawable = metalLayer?.nextDrawable() else { return }
    let renderPassDescriptor = MTLRenderPassDescriptor()
    renderPassDescriptor.colorAttachments[0].texture = drawable.texture
    renderPassDescriptor.colorAttachments[0].loadAction = .clear
    renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(
      red: 0.0,
      green: 104.0/225.0,
      blue: 55/255.0,
      alpha: 1.0)
    
    let commandBuffer = commandQueue.makeCommandBuffer()!
    let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
    renderEncoder.setRenderPipelineState(pipelineState)
    renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
    renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3, instanceCount: 1)
    renderEncoder.endEncoding()
    commandBuffer.present(drawable)
    commandBuffer.commit()
    
  }
  
  @objc func gameLoop() {
    autoreleasepool {
      self.render()
    }
  }
}
