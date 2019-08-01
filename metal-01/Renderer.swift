//
//  Renderer.swift
//  metal-01
//
//  Created by Tim Smith on 31/07/19.
//  Copyright © 2019 Tim Smith. All rights reserved.
//

import MetalKit

class Renderer: NSObject {
    struct Vertex {
        var position: float3
        var color: float4
        var texture: float2
    }
    var vertices: [Vertex] = [
        Vertex(position: float3(-1,1,0),
               color: float4(1,0,0,1), texture: float2(0,1)), // v0
        Vertex(position: float3(-1,-1,0),
               color:float4(0,1,0,1), texture: float2(0,0)),// v1
        Vertex(position: float3(1,-1,0),
               color: float4(0,0,1,1), texture: float2(1,0)),// v2
        Vertex(position: float3(1,1,0),
               color: float4(1,0,1,1), texture: float2(1,1)) // v3
    ]
    
    var indices: [UInt16] = [
        0, 1, 2,
        2, 3, 0
    ]
    var texture: MTLTexture?
    var device: MTLDevice!
    var commandQueue: MTLCommandQueue!
    
    var pipelineState: MTLRenderPipelineState?
    
    var vertexBuffer: MTLBuffer?
    var indexBuffer: MTLBuffer?
    
    var time: Float = 0
    
    struct Constants {
        var animateBy: Float = 0.0
    }
    var constants = Constants()
    
    private func aniamatePlane(){
        //time += 1 / Float(view.preferredFramesPerSecond)
        let animateBy = abs(sin(time)/2 + 0.5)
        constants.animateBy = animateBy
    }

    var sourceTexture: MTLTexture!
    var context: CIContext!
    var fragmentFunctionName: String = "fragment_shader"
    var vertexFunctionName: String = "vertex_shader"
    
    let filter = CIFilter(name: "CIGaussianBlur")!
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    
    init(device: MTLDevice) {
        super.init()
        self.device = device
        commandQueue = device.makeCommandQueue()
        buildModel()
        buildPipelineState()
    }
    
    init(device: MTLDevice, imageName: String) {
        super.init()
        if let texture = setTexture(device: device, imageName: imageName){
            self.texture = texture
            fragmentFunctionName = "textured_fragment"
        }
        self.device = device
        commandQueue = device.makeCommandQueue()
    }
    
    private func buildModel() {
                vertexBuffer = device.makeBuffer(bytes: vertices, length: vertices.count * MemoryLayout<Vertex>.stride, options: [])
                indexBuffer = device.makeBuffer(bytes: indices, length: indices.count * MemoryLayout<UInt16>.size, options: [])
    }
    
    private func buildPipelineState(){
        let library = device.makeDefaultLibrary()
        let vertexFunction = library?.makeFunction(name: "vertex_shader")
        let fragmentFunction = library?.makeFunction(name: "fragment_shader")
        
        let pipelineDescripter = MTLRenderPipelineDescriptor()
        pipelineDescripter.vertexFunction = vertexFunction
        pipelineDescripter.fragmentFunction = fragmentFunction
        pipelineDescripter.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        let vertexDescripter = MTLVertexDescriptor()
        
        vertexDescripter.attributes[0].format = .float3
        vertexDescripter.attributes[0].offset = 0
        vertexDescripter.attributes[0].bufferIndex = 0
        
        vertexDescripter.attributes[1].format = .float4
        vertexDescripter.attributes[1].offset = MemoryLayout<float3>.stride
        vertexDescripter.attributes[1].bufferIndex = 0
        
        vertexDescripter.attributes[2].format = .float2
        vertexDescripter.attributes[2].offset = MemoryLayout<float3>.stride +
            MemoryLayout<float4>.stride
        vertexDescripter.attributes[2].bufferIndex = 0
        
        vertexDescripter.layouts[0].stride = MemoryLayout<Vertex>.stride
        
        pipelineDescripter.vertexDescriptor = vertexDescripter
        
        do {
            pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescripter)
        } catch let error as NSError {
            print("error: \(error.localizedDescription)")
        }
    }
}

extension Renderer: Texturable{}

extension Renderer: MTKViewDelegate{
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    
    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable,
            let pipelineState = pipelineState,
            let indexBuffer = indexBuffer,
            let descriptor = view.currentRenderPassDescriptor else {
                return
        }
        let commandBuffer = commandQueue.makeCommandBuffer()
        let commandEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: descriptor)
        commandEncoder?.setRenderPipelineState(pipelineState)
        commandEncoder?.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        commandEncoder?.setVertexBytes(&constants, length: MemoryLayout<Constants>.stride, index: 1)
        
        commandEncoder?.drawIndexedPrimitives(type: .triangle, indexCount: indices.count, indexType: .uint16, indexBuffer: indexBuffer, indexBufferOffset: 0)
        
        commandEncoder?.setFragmentTexture(texture, index: 0)
        commandEncoder?.endEncoding()
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }
}
