import SceneKitPlus
import MeshGenerator
import SceneKit

//MARK: ProteinKit error enums
public enum ProteinKitError: Error {
    case badMesh(String)
    
    var description: String {
        switch self {
        case .badMesh:
            return "Error generating mesh"
        }
    }
}

//MARK: Main class. Generate SCNNode

public class ProteinKit {
    
    let residues: [Residue]
    
    public init(residues: [Residue]) {
        self.residues = residues
    }
    
    public func getProteinNode() throws -> SCNNode {
        
        guard let meshes = ProteinMesh().createChainMesh(chain: residues) else {
            throw ProteinKitError.badMesh("Error generating mesh")
        }
        
        guard meshes.count == residues.count - 5 else {throw ProteinKitError.badMesh("Residue count do not match with mesh")}
        
        // Each mesh inside meshes is one aminoacid
        return aminoNode(fromMesh: meshes)
        
    }
    
    private func rainbowNode(_ i: Int) -> UColor {
        
        var j = CGFloat(i)
        
        if j > 1530 {j = 0}
        
        if j <= 255 {
            return UColor(red: 1, green: j/255, blue: 0, alpha: 1.0)
        }
        if j > 255 && j <= 510 {
            j -= 255
            return UColor(red: (255-j)/255, green: 1, blue: 0, alpha: 1.0)
        }
        if j > 510 && j <= 765 {
            j -= 255*2
            return UColor(red: 0, green: 1, blue: j/255, alpha: 1.0)
        }
        if j > 765 && j <= 1020 {
            j -= 255*3
            return UColor(red: 0, green: (255-j)/255, blue: 1, alpha: 1.0)
        }
        if j > 1020 && j <= 1275 {
            j -= 255*4
            return UColor(red: j/255, green: 0, blue: 1, alpha: 1.0)
        }
        if j > 1275 && j <= 1530 {
            j -= 255*5
            return UColor(red: 1, green: 0, blue: (255-j)/255, alpha: 1.0)
        }
        else {return UColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0)}
    }
    
    private func aminoNode(fromMesh meshes: [Mesh]) -> SCNNode {
        
        let aminoNodes = SCNNode() // Root node for the amino acids
        
        for (m, mesh) in meshes.enumerated() {
            let geometry = SCNGeometry(mesh)
            geometry.name = residues[m].structure.rawValue
            
            let material = SCNMaterial()
            material.diffuse.contents = rainbowNode(m)
            geometry.materials = [material]
            
            let node = SCNNode(
            //node.name = residues[m].type.symbol + "\(m+1)"
            node.name = "aa"
            aminoNodes.addChildNode(node)
        }
        
        return aminoNodes
    }
}

