//
//  File.swift
//  
//
//  Created by Christian Dominguez on 30/6/22.
//

import SceneKitPlus

public class ProteinNode: SCNNode {
    var aa: AminoAcid = .ala
    
    public init(proteinGeometry: SCNGeometry?) {
        super.init(geometry: geometry)
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}
