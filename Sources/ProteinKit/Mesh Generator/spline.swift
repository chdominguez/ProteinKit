//
//  File.swift
//  
//
//  Created by Christian Dominguez on 17/6/22.
//

import SceneKitPlus

internal func splineForPlanes(_ p1: PeptidePlane, _ p2: PeptidePlane, _ p3: PeptidePlane, _ p4: PeptidePlane, _ n: Int, _ u: Double, _ v: Double) -> [SCNVector3] {
    let g1 = p1.position + (p1.side * u) + (p1.normal * v)
    let g2 = p2.position + (p2.side * u) + (p2.normal * v)
    let g3 = p3.position + (p3.side * u) + (p3.normal * v)
    let g4 = p4.position + (p4.side * u) + (p4.normal * v)
    return spline(g1, g2, g3, g4, n)
}

internal func spline(_ v1: SCNVector3, _ v2: SCNVector3, _ v3: SCNVector3, _ v4: SCNVector3, _ n: Int) -> [SCNVector3] {
    let n1 = Double(n)
    let n2 = Double(n * n)
    let n3 = Double(n * n * n)
    
    let s = SCNMatrix4([
        6 / n3, 0, 0, 0,
        6 / n3, 2 / n2, 0, 0,
        1 / n3, 1 / n2, 1 / n1, 0,
        0, 0, 0, 1, ])
    
    let b = SCNMatrix4([
        -1, 3, -3, 1,
         3, -6, 3, 0,
         -3, 0, 3, 0,
         1, 4, 1, 0,
    ]) * (1.0/6.0)
    
    let g = SCNMatrix4([
        v1.dx, v1.dy, v1.dz, 1,
        v2.dx, v2.dy, v2.dz, 1,
        v3.dx, v3.dy, v3.dz, 1,
        v4.dx, v4.dy, v4.dz, 1,
    ])
        
    var m1 = s * b
    
    var m = m1 * g
    
    var result: [SCNVector3] = []
    
    var v = SCNVector3Make(m.m41 / m.m44, m.m42 / m.m44, m.m43 / m.m44)
    
    v.roundTo(n: 10)
    result.append(v)

    for k in 0..<n {
        m.m41 = m.m41 + m.m31
        m.m42 = m.m42 + m.m32
        m.m43 = m.m43 + m.m33
        m.m44 = m.m44 + m.m34
        m.m31 = m.m31 + m.m21
        m.m32 = m.m32 + m.m22
        m.m33 = m.m33 + m.m23
        m.m34 = m.m34 + m.m24
        m.m21 = m.m21 + m.m11
        m.m22 = m.m22 + m.m12
        m.m23 = m.m23 + m.m13
        m.m24 = m.m24 + m.m14
        v = SCNVector3Make(m.m41 / m.m44, m.m42 / m.m44, m.m43 / m.m44)
        v.roundTo(n: 10)
        result.append(v)
    }
    return result
}
