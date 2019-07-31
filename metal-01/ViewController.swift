//
//  ViewController.swift
//  metal-01
//
//  Created by Tim Smith on 31/07/19.
//  Copyright © 2019 Tim Smith. All rights reserved.
//

import UIKit
import MetalKit

enum Colors{
static let blue = MTLClearColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0)
}

class ViewController: UIViewController {

    var metalView: MTKView {
        return view as! MTKView
    }
    var renderer: Renderer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        metalView.device = MTLCreateSystemDefaultDevice()
        guard let device = metalView.device else {
            fatalError("device not created")
        }
        metalView.clearColor = Colors.blue
        renderer = Renderer(device: device)
        metalView.delegate = renderer
    }
}



