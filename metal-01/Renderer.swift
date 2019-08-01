//
//  Renderer.swift
//  metal-01
//
//  Created by Tim Smith on 31/07/19.
//  Copyright © 2019 Tim Smith. All rights reserved.
//

import MetalKit

class Renderer: NSObject {
    var texture: MTLTexture?
    var device: MTLDevice!
    var commandQueue: MTLCommandQueue!
    var sourceTexture: MTLTexture!
    var context: CIContext!
    var fragmentFunctionName: String = ""
    
    let filter = CIFilter(name: "CIGaussianBlur")!
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    
    init(device: MTLDevice) {
        super.init()
        self.device = device
        commandQueue = device.makeCommandQueue()
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
}

extension Renderer: Texturable{}

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
        commandEncoder?.setFragmentTexture(texture, index: 0)
        commandEncoder?.endEncoding()
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }
    func ScaleImageToView(view: MTKView, ciImage: CIImage){
        // okay, `output` is the CIImage we want to display
        // scale it down to aspect-fit inside the MTKView
        var r = view.bounds
        r.size = view.drawableSize
    }
    func renderImage(view: MTKView, ciImage: CIImage)  {
        // minimal dance required in order to draw: render, present, commit
        let buffer = self.commandQueue.makeCommandBuffer()!
        context = CIContext(mtlDevice: device)
        buffer.present(view.currentDrawable!)
        buffer.commit()
    }
}
