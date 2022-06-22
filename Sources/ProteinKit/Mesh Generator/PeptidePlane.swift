//
//  File.swift
//  
//
//  Created by Christian Dominguez on 17/6/22.
//

import SceneKitPlus

//MARK: PeptidePlane
internal class PeptidePlane {
    
    public init(_ r1: Residue, _ r2: Residue, _ r3: Residue, _ position: SCNVector3, _ normal: SCNVector3, _ forward: SCNVector3, _ side: SCNVector3, _ flipped: Bool) {
        self.residue1 = r1
        self.residue2 = r2
        self.residue3 = r3
        self.position = position
        self.normal = normal
        self.forward = forward
        self.side = side
        self.flipped = flipped
    }
    
    let residue1: Residue
    let residue2: Residue
    let residue3: Residue
    var position: SCNVector3
    var normal: SCNVector3
    var forward: SCNVector3
    var side: SCNVector3
    var flipped: Bool
    
    func flip() {
        self.side = -self.side
        self.normal = -self.normal
        self.flipped.toggle()
    }
    
    func transition() -> (SecondaryStructure, SecondaryStructure) {
        let t1 = self.residue1.structure
        let t2 = self.residue2.structure
        let t3 = self.residue3.structure
        
        var type1 = t2
        var type2 = t2
        
        if t2.priority > t1.priority && t2.priority == t3.priority {
            type1 = t1
        }
        
        if t2.priority > t3.priority && t1.priority == t2.priority {
            type2 = t3
        }
        
        return (type1, type2)
        
    }
    
    func segmentColors() -> (UColor, UColor) {
        let (type1, type2) = self.transition()
        
        var c1 = UColor()
        var c2 = UColor()
        
        switch type1 {
        case .coil, .turn, .turnI, .turnIp, .turnII, .turnIIp, .turnIV, .turnVIa, .turnVIb, .turnVIII:
            c1 = UColor(red: 255/255, green: 183/255, blue: 51/255, alpha: 1)
        case .alphaHelix, .helix310, .phiHelix:
            c1 = UColor(red: 245/255, green: 115/255, blue: 54/255, alpha: 1)
        case .strand, .bridge:
            c1 = UColor(red: 4/255, green: 120/255, blue: 120/255, alpha: 1)
        default:
            c1 = .black
        }
        
        switch type2 {
        case .coil, .turn, .turnI, .turnIp, .turnII, .turnIIp, .turnIV, .turnVIa, .turnVIb, .turnVIII:
            c2 = UColor(red: 255/255, green: 183/255, blue: 51/255, alpha: 1)
        case .alphaHelix, .helix310, .phiHelix:
            c2 = UColor(red: 245/255, green: 115/255, blue: 54/255, alpha: 1)
        case .strand, .bridge:
            c2 = UColor(red: 4/255, green: 120/255, blue: 120/255, alpha: 1)
        default:
            c2 = .black
        }
        
        return (c1, c2)
        
    }
    
    func segmentProfiles(pp2: PeptidePlane, n: Int) -> ([SCNVector3], [SCNVector3]) {
        let type0 = self.residue1.structure
        let (type1, type2) = self.transition()
        
        let ribbonWidth: Double = 2
        let ribbonHeight: Double = 0.125
        let ribbonOffset: Double = 1.5
        let arrowHeadWidth: Double = 3
        let arrowWidth: Double = 2
        let arrowHeight: Double = 0.5
        let tubeSize: Double = 0.75
        
        var offset1 = ribbonOffset
        var offset2 = ribbonOffset
        
        if self.flipped {
            offset1 *= -1
        }
        
        if pp2.flipped {
            offset2 *= -1
        }
        
        var p1: [SCNVector3] = []
        var p2: [SCNVector3] = []
        
        switch type1 {
        case .alphaHelix:
            if type0 == .strand || type0 == .bridge {
                p1 = roundedRectangleProfile(n, 0, 0)
            }
            else {
                p1 = roundedRectangleProfile(n, ribbonWidth, ribbonHeight)
            }
            
            p1 = translateProfile(p1, 0, offset1)
            
        case .strand:
            if type2 == .strand {
                p1 = rectangleProfile(n, arrowWidth, arrowHeight)
            } else {
                p1 = rectangleProfile(n, arrowHeadWidth, arrowHeight)
            }
        default:
            if type0 == .strand {
                p1 = ellipseProfile(n, 0, 0)
            } else {
                p1 = ellipseProfile(n, tubeSize, tubeSize)
            }
        }
        
        switch type2 {
        case .alphaHelix:
            p2 = roundedRectangleProfile(n, ribbonWidth, ribbonHeight)
            p2 = translateProfile(p2, 0, offset2)
        case .strand:
            p2 = rectangleProfile(n, arrowWidth, arrowHeight)
        default:
            p2 = ellipseProfile(n, tubeSize, tubeSize)
        }
        
        if type1 == .strand && type2 != .strand {
            p2 = rectangleProfile(n, 0, arrowHeight)
        }
        return (p1, p2)
    }
    
}
