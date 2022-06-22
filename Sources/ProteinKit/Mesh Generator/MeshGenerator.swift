//
//  File.swift
//  
//
//  Created by Christian Dominguez on 10/6/22.
//

import SceneKitPlus
import SwiftUI
import SceneKit
import MeshGenerator

public struct pMesh {
    var triangles: [Triangle] = []
    var lines: [LineSegment] = []
    
    mutating func add(_ m: pMesh) {
        self.triangles += m.triangles
        self.lines += m.lines
    }
}

//MARK: Internal mesh profile functions
internal func roundedRectangleProfile(_ n: Int, _ w: Double, _ h: Double) -> [SCNVector3] {
    var result: [SCNVector3] = []
    let r = h / 2
    let hw = w/2 - r
    let hh = h / 2
    let segments = [
        [SCNVector3Make(hw, hh, 0), SCNVector3Make(-hw, hh, 0)],
        [SCNVector3Make(-hw, 0, 0), SCNVector3Make(0, 0, 0)],
        [SCNVector3Make(-hw, -hh, 0), SCNVector3Make(hw, -hh, 0)],
        [SCNVector3Make(hw, 0, 0), SCNVector3Make(0, 0, 0)]
    ]
    
    let m = n / 4
    var t: Double = 0
    
    // si indicates the s(ith) segment integer position inside the array
    for (si, segment) in segments.enumerated() {
        for i in 0..<m {
            t = Double(i) / Double(m)
            var p = SCNVector3Make(0, 0, 0)
            
            switch si {
            case 0, 2:
                p = segment[0].lerp(segment[1], t)
            case 1:
                let a = Double.pi / 2 + Double.pi * t
                let x = cos(a) * r
                let y = sin(a) * r
                p = segment[0] + SCNVector3Make(x, y, 0)
            case 3:
                let a = 3*Double.pi / 2 + Double.pi * t
                let x = cos(a) * r
                let y = sin(a) * r
                p = segment[0] + SCNVector3Make(x, y, 0)
            default:
                fatalError("Error in roundedRectangleProfile. 'si' (segments) exceeded the valid maximum number defined above (3)")
            }
            
            result.append(p)
            
        }
    }
    return result
}

internal func rectangleProfile(_ n: Int, _ w: Double, _ h: Double) -> [SCNVector3] {
    var result: [SCNVector3] = []
    
    let hw = w / 2
    let hh = h / 2
    
    let segments = [
        [SCNVector3Make(hw, hh, 0), SCNVector3Make(-hw, hh, 0)],
        [SCNVector3Make(-hw, hh, 0), SCNVector3Make(-hw, -hh, 0)],
        [SCNVector3Make(-hw, -hh, 0), SCNVector3Make(hw, -hh, 0)],
        [SCNVector3Make(hw, -hh, 0), SCNVector3Make(hw, hh, 0)]
    ]
    
    let m = n / 4
    
    for s in segments {
        for i in 0..<m {
            let t = Double(i) / Double(m)
            let p = s[0].lerp(s[1], t)
            result.append(p)
        }
    }
    
    return result
}

internal func ellipseProfile(_ n: Int, _ w: Double, _ h: Double) -> [SCNVector3] {
    var result: [SCNVector3] = []
    for i in 0..<n {
        let t = Double(i) / Double(n)
        let a = t*2*Double.pi + Double.pi / 4
        let x = cos(a) * w / 2
        let y = sin(a) * h / 2
        result.append(SCNVector3Make(x, y, 0))
    }
    return result
}

internal func translateProfile(_ p1: [SCNVector3], _ dx: Double, _ dy: Double) -> [SCNVector3] {
    var result: [SCNVector3] = []
    
    for i in 0..<p1.count {
        result.append( p1[i] + SCNVector3Make(dx, dy, 0) )
    }
    
    return result
    
}

//MARK: ProteinKit error enums
public enum ProteinKitError: Error {
    case badMesh
}

//MARK: Main class. Generate SCNNode

public class ProteinNode {
    
    let residues: [Residue]
    
    public init(residues: [Residue]) {
        self.residues = residues
    }
    
    public func getProteinNode() throws -> SCNNode {
        
        guard let meshes = ProteinMesh().createChainMesh(chain: residues) else {throw ProteinKitError.badMesh}
        
        let node = SCNNode()
        
        let colors: [UColor] = [.red, .blue, .brown, .cyan, .systemPink, .purple, .gray, .black, .white]
        
        var i = 0
        
        for mesh in meshes {
            
            
            let material = SCNMaterial()
            material.diffuse.contents = colors[i]
            let geo = SCNGeometry(mesh)
            geo.materials = [material]
            node.addChildNode(SCNNode(geometry: geo))
            
            i += 1
            
            if i > colors.count - 1 {i = 0}
            
        }

        return node
        
    }
    
}


//MARK: Protein mesh generator
private class ProteinMesh {
    
    private func newPeptidePlane(r1: Residue, r2: Residue, r3: Residue) -> PeptidePlane? {
        
        guard let ca1 = r1.atoms.first(where: { $0.info == "CA" }), let ca2 = r2.atoms.first(where: { $0.info == "CA" }), let o1 = r1.atoms.first(where: { $0.info == "O" }) else { return nil }
        
        let a = (ca2.position - ca1.position).normalized()
        let b = (o1.position - ca1.position).normalized()
        let c = a.crossProduct(b).normalized()
        let d = c.crossProduct(a).normalized()
        let p = (ca1.position + ca2.position) / 2
        
        return PeptidePlane(r1, r2, r3, p, c, a, d, false)
        
    }
    
    internal func createChainMesh(chain: [Residue]) -> [Mesh]? {
        var mesh: [Mesh] = []
        
        var planes: [PeptidePlane] = []
        
        
        #warning("account for errors in pdb with too short chains")
        #warning("PDBREADER THERE ARE ATOMS WITH ' primas")
        for i in 0..<chain.count - 2 {
            guard let p = newPeptidePlane(r1: chain[i], r2: chain[i+1], r3: chain[i+2]) else { return nil }
            planes.append(p)
        }
        
        var prev = SCNVector3Make(0, 0, 0)
        
        for (i, p) in planes.enumerated() {
            if i > 0 && p.side.dotProduct(prev) < 0 {
                p.flip()
            }
            prev = p.side
        }
        
        let n = planes.count - 3
        
        for i in 0..<n {
            let pp1 = planes[i]
            let pp2 = planes[i+1]
            let pp3 = planes[i+2]
            let pp4 = planes[i+3]
            let m = createSegmentMesh(i, n, pp1, pp2, pp3, pp4)
            mesh.append(m)
        }
        
        return mesh
    }
    
    private func createSegmentMesh(_ i: Int, _ n: Int, _ pp1: PeptidePlane, _ pp2: PeptidePlane, _ pp3: PeptidePlane, _ pp4: PeptidePlane) -> Mesh {
        let splineSteps = 32
        let profileDetail = 16
        let type0 = pp2.residue1.structure
        
        let (type1, type2) = pp2.transition()
        
        let (c1, c2) = pp2.segmentColors()
        
        var (profile1, profile2) = pp1.segmentProfiles(pp2: pp2, n: profileDetail)
        
        var easeFunc: (Double) -> Double
        
        easeFunc = linear(_:)
        
        if !(type0 == .strand && type2 != .strand) {
            easeFunc = inOutQuad(_:)
        }
        if type0 == .strand && type1 != .strand {
            easeFunc = OutCirc(_:)
        }
        
        if i == 0 {
            profile1 = ellipseProfile(profileDetail, 0, 0)
            easeFunc = OutCirc(_:)
        } else if i == n-1 {
            profile2 = ellipseProfile(profileDetail, 0, 0)
            easeFunc = InCirc(_:)
        }
        
        var splines1: [[SCNVector3]] = []
        var splines2: [[SCNVector3]] = []
        
        let range1 = 0..<profile1.count
        
        for i in range1 {
            let p1 = profile1[i]
            let p2 = profile2[i]
            splines1.append(splineForPlanes(pp1, pp2, pp3, pp4, splineSteps, p1.dx, p1.dy))
            splines2.append(splineForPlanes(pp1, pp2, pp3, pp4, splineSteps, p2.dx, p2.dy))
        }
        
        var triangles: [Triangle] = []
        var lines: [LineSegment] = []
        
        for i in 0..<splineSteps {
            var t0 = easeFunc(Double(i)/Double(splineSteps))
            var t1 = easeFunc(Double(i+1)/Double(splineSteps))
            
            if i == 0 && type1 == .strand && type2 != .strand {
                let p00 = splines1[0][i]
                let p10 = splines1[profileDetail/4][i]
                let p11 = splines1[2*profileDetail/4][i]
                let p01 = splines1[3*profileDetail/4][i]
                triangulateQuad(&triangles, p00, p01, p11, p10, c1, c1, c1, c1)
            }
            
            for j in 0..<profileDetail {
               let p100 = splines1[j][i]
               let p101 = splines1[j][i+1]
               let p110 = splines1[(j+1)%profileDetail][i]
               let p111 = splines1[(j+1)%profileDetail][i+1]
               let p200 = splines2[j][i]
               let p201 = splines2[j][i+1]
               let p210 = splines2[(j+1)%profileDetail][i]
               let p211 = splines2[(j+1)%profileDetail][i+1]
               let p00 = p100.lerp(p200, t0)
               let p01 = p101.lerp(p201, t1)
               let p10 = p110.lerp(p210, t0)
               let p11 = p111.lerp(p211, t1)
//               let c00 = c1.lerp(c2, t0)
//               let c01 = c1.lerp(c2, t1)
//               let c10 = c1.lerp(c2, t0)
//               let c11 = c1.lerp(c2, t1)
                #warning("All c1")
                triangulateQuad(&triangles, p10, p11, p01, p00, c1, c1, c1, c1)
            }
        }
        
        return Mesh(triangles)
    }
    
    
}

//MARK: Internal functions

internal func linear(_ t: Double) -> Double {
    return t
}

internal func inQuad(_ t: Double) -> Double {
    return t * t
}

internal func outQuad(_ t: Double) -> Double {
    return -t * (t-2)
}

internal func inOutQuad(_ t: Double) -> Double {
    if t < 0.5 {
        return 2 * t * t
    } else {
        let t2 = 2*t - 1
        return -0.5 * (t2*(t2-2) - 1)
    }
}

internal func InCubic(_ t: Double) -> Double {
    return t * t * t
}

internal func OutCubic(_ t: Double) -> Double {
    let t2 = t - 1
    return t2*t2*t2 + 1
}

internal func InOutCubic(_ t: Double) -> Double {
    var t2 = t*2
    if t2 < 1 {
        return 0.5 * t2 * t2 * t2
    } else {
        t2 = t - 2
        return 0.5 * (t2*t2*t2 + 2)
    }
}

internal func InQuart(_ t: Double) -> Double {
    return t * t * t * t
}

internal func OutQuart(_ t: Double) -> Double {
    let t2 = t - 1
    return -(t2*t2*t2*t2 - 1)
}

internal func InOutQuart(_ t: Double) -> Double {
    var t2 = t * 2
    if t2 < 1 {
        return 0.5 * t2 * t2 * t2 * t2
    } else {
        t2 -= 2
        return -0.5 * (t2*t2*t2*t2 - 2)
    }
}

internal func InQuint(_ t: Double) -> Double {
    return t * t * t * t * t
}

internal func OutQuint(_ t: Double) -> Double {
    let t2 = t - 1
    return t2*t2*t2*t2*t2 + 1
}

internal func InOutQuint(_ t: Double) -> Double {
    var t2 = t * 2
    if t2 < 1 {
        return 0.5 * t2 * t2 * t2 * t2 * t2
    } else {
        t2 = t - 2
        return 0.5 * (t2*t2*t2*t2*t2 + 2)
    }
}

internal func InSine(_ t: Double) -> Double {
    return -1*cos(t*Double.pi/2) + 1
}

internal func OutSine(_ t: Double) -> Double {
    return sin(t * Double.pi / 2)
}

internal func InOutSine(_ t: Double) -> Double {
    return -0.5 * (cos(Double.pi*t) - 1)
}

internal func InExpo(_ t: Double) -> Double {
    if t == 0 {
        return 0
    } else {
        return pow(2, 10*(t-1))
    }
}

internal func OutExpo(_ t: Double) -> Double {
    if t == 1 {
        return 1
    } else {
        return 1 - pow(2, -10*t)
    }
}

internal func InOutExpo(_ t: Double) -> Double {
    if t == 0 {
        return 0
    } else if t == 1 {
        return 1
    } else {
        if t < 0.5 {
            return 0.5 * pow(2, (20*t)-10)
        } else {
            return 1 - 0.5*pow(2, (-20*t)+10)
        }
    }
}

internal func InCirc(_ t: Double) -> Double {
    return -1 * (sqrt(1-t*t) - 1)
}

internal func OutCirc(_ t: Double) -> Double {
    let t2 = t - 1
    return sqrt(1 - (t2 * t2))
}

internal func InOutCirc(_ t: Double) -> Double {
    var t2 = 2*t
    if t2 < 1 {
        return -0.5 * (sqrt(1-t2*t2) - 1)
    } else {
        t2 = t2 - 2
        return 0.5 * (sqrt(1-t2*t2) + 1)
    }
}

internal func InElastic(_ t: Double) -> Double {
    return InElasticFunction(0.5)(t)
}

internal func OutElastic(_ t: Double) -> Double {
    return OutElasticFunction(0.5)(t)
}

internal func InOutElastic(_ t: Double) -> Double {
    return InOutElasticFunction(0.5)(t)
}

internal func InElasticFunction(_ p: Double) -> (Double) -> (Double) {
    return { t in
        let t2 = t-1
        return -1 * (pow(2, 10*t2) * sin((t2-p/4)*(2*Double.pi)/p))
    }
}

internal func OutElasticFunction(_ p: Double) -> (Double) -> (Double) {
    return { t in
        return pow(2, -10*t)*sin((t-p/4)*(2*Double.pi/p)) + 1
    }
}

internal func InOutElasticFunction(_ p: Double) -> (Double) -> (Double) {
    return { t in
        var t2 = t*2
        if t2 < 1 {
            t2 -= 1
            return -0.5 * (pow(2, 10*t2) * sin((t2-p/4)*2*Double.pi/p))
        } else {
            t2 -= 1
            return pow(2, -10*t2)*sin((t2-p/4)*2*Double.pi/p)*0.5 + 1
        }
    }
}

internal func InBack(_ t: Double) -> Double {
    let s = 1.70158
    return t * t * ((s+1)*t - s)
}

internal func OutBack(_ t: Double) -> Double {
    let s = 1.70158
    let t2 = t - 1
    return t2*t2*((s+1)*t2+s) + 1
}

internal func InOutBack(_ t: Double) -> Double {
    var s = 1.70158
    var t2 = t * 2
    if t < 1 {
        s *= 1.525
        return 0.5 * (t2 * t2 * ((s+1)*t2 - s))
    } else {
        t2 -= 2
        s *= 1.525
        return 0.5 * (t2*t2*((s+1)*t2+s) + 2)
    }
}

internal func InBounce(_ t: Double) -> Double {
    return 1 - OutBounce(1-t)
}

internal func OutBounce(_ t: Double) -> Double {
    if t < 4/11.0 {
        return (121 * t * t) / 16.0
    } else if t < 8/11.0 {
        return (363 / 40.0 * t * t) - (99 / 10.0 * t) + 17/5.0
    } else if t < 9/10.0 {
        return (4356 / 361.0 * t * t) - (35442 / 1805.0 * t) + 16061/1805.0
    } else {
        return (54 / 5.0 * t * t) - (513 / 25.0 * t) + 268/25.0
    }
}

internal func InOutBounce(_ t: Double) -> Double {
    if t < 0.5 {
        return InBounce(2*t) * 0.5
    } else {
        return OutBounce(2*t-1)*0.5 + 0.5
    }
}

internal func InSquare(_ t: Double) -> Double {
    if t < 1 {
        return 0
    } else {
        return 1
    }
}

internal func OutSquare(_ t: Double) -> Double {
    if t > 0 {
        return 1
    } else {
        return 0
    }
}

internal func InOutSquare(_ t: Double) -> Double {
    if t < 0.5 {
        return 0
    } else {
        return 1
    }
}

//MARK: Extra funcs

func triangulateQuad(_ triangles: inout [Triangle], _ p1: SCNVector3, _ p2: SCNVector3, _ p3: SCNVector3, _ p4: SCNVector3, _ c1: UColor, _ c2: UColor, _ c3: UColor, _ c4: UColor) {
    
    let vertex1 = Vertex(x: p1.dx, y: p1.dy, z: p1.dz)
    let vertex2 = Vertex(x: p2.dx, y: p2.dy, z: p2.dz)
    let vertex3 = Vertex(x: p3.dx, y: p3.dy, z: p3.dz)
    let vertex4 = Vertex(x: p4.dx, y: p4.dy, z: p4.dz) // V4 same as V1 why?

    if vertex1 == vertex4 {return}
    if vertex1 == vertex2 {return}
    if vertex1 == vertex3 {return}
    
    if vertex2 == vertex3 {return}
    if vertex3 == vertex4 {return}
    
    guard let t1 = Triangle([vertex1, vertex2, vertex3]) else {fatalError()}
    guard let t2 = Triangle([vertex1, vertex3, vertex4]) else {fatalError()}
    
    triangles.append(t1)
    triangles.append(t2)

}
