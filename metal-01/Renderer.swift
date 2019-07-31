//
//  Renderer.swift
//  metal-01
//
//  Created by Tim Smith on 31/07/19.
//  Copyright © 2019 Tim Smith. All rights reserved.
//

import MetalKit

class Renderer: NSObject {
    var device: MTLDevice!
    var commandQueue: MTLCommandQueue!
    
    init(device: MTLDevice) {
        self.device = device
        commandQueue = device.makeCommandQueue()
        super.init()
    }
}

extension Renderer: MTKViewDelegate{
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    
    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable,
            let descriptor = view.currentRenderPassDescriptor else {
                return
        }
        let commandBuffer = commandQueue.makeCommandBuffer()
        let commandEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: descriptor)
        commandEncoder?.endEncoding()
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }
}
