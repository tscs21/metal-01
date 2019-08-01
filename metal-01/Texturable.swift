//
//  Texturable.swift
//  metal-01
//
//  Created by Tim Smith on 1/08/19.
//  Copyright © 2019 Tim Smith. All rights reserved.
//

import MetalKit

protocol Texturable {
    var texture: MTLTexture? {get set}
}

extension Texturable{
    func setTexture(device: MTLDevice, imageName: String)->MTLTexture?{
        let textureLoader = MTKTextureLoader(device: device)
        var texture: MTLTexture? = nil
        //let textLoaderOptions: MTKTextureLoader.Option
        if let textureURL = Bundle.main.url(forResource: imageName, withExtension: nil){
            do{
                texture = try textureLoader.newTexture(URL: textureURL, options: [:])
            }catch{
                print("texture not created")
            }
        }
        return texture
    }
}
