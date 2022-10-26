import SceneKitPlus
import MeshGenerator
import SwiftUI
import SceneKit

//MARK: ProteinKit error enums
public enum ProteinKitError: Error {
    case badMesh(String)
    case noAccess
    case PDBError

    var description: String {
        switch self {
        case .badMesh:
            return "Error generating mesh"
        case .noAccess:
            return "Cannot open file"
        case .PDBError:
            return "Error reading PDB"
        }
    }
}

//MARK: Main class. Generate SCNNode

public class ProteinKit {
    
    private let moleculeName: String
    
    private let residues: [Residue]
    
    private let atomGeometries: AtomGeometries
    
    public init(residues: [Residue], colorSettings: ProteinColors? = nil, moleculeName: String? = nil) {
        self.residues = residues
        self.moleculeName = moleculeName ?? "Protein"
        if let colorSettings = colorSettings {
            self.atomGeometries = AtomGeometries(colors: colorSettings)
        }
        else {
            self.atomGeometries = AtomGeometries(colors: ProteinColors())
        }
    }
    
    #warning("Fix init for non-protein only atoms")
    public init() {
        self.atomGeometries = AtomGeometries(colors: ProteinColors())
        self.residues = []
        self.moleculeName = "Molecule"
    }
    
    public func getProteinNode() throws -> SCNNode {
        
        guard let meshes = ProteinMesh().createChainMesh(chain: residues) else {
            throw ProteinKitError.badMesh("Error generating mesh")
        }
        
        // Each mesh inside meshes is one aminoacid
        #warning("Why 5?")
        guard meshes.count == residues.count - 5 else {throw ProteinKitError.badMesh("Residue count do not match with mesh")}
        
        return generateNodes(residues: residues, mesh: meshes)
        
    }
    
    private func rainbowColor(_ i: Int) -> UColor {
        
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
    
    private func generateNodes(residues: [Residue], mesh: [Mesh]) -> SCNNode {
        let node = SCNNode()
        node.name = moleculeName
        aminoNode(fromMesh: mesh, to: node)
        return node
    }
    
    private func aminoNode(fromMesh meshes: [Mesh], to rootNode: SCNNode) {
        let helixNodes = SCNNode()
        helixNodes.name = "Helices"
        let sheetsNodes = SCNNode()
        sheetsNodes.name = "Sheets"
        let otherNodes = SCNNode()
        otherNodes.name = "Other"
        DispatchQueue.global(qos: .userInitiated).async { [self] in
            for (m, mesh) in meshes.enumerated() {
                let geometry = SCNGeometry(mesh)
                let material = SCNMaterial()
                #warning("Temporary disable rainbow for color perfomance")
                //material.diffuse.contents = rainbowColor(m)
                material.diffuse.contents = UColor.brown
                geometry.materials = [material]
          
                let node = SCNNode(geometry: geometry)
                node.name = "C_\(residues[m].type.code)_\(m)_\(moleculeName)_\(residues[m].structure.priority)"
                switch residues[m].structure {
                case .alphaHelix, .helix310, .phiHelix:
                    helixNodes.addChildNode(node)
                case .strand:
                    sheetsNodes.addChildNode(node)
                default:
                    otherNodes.addChildNode(node)
                }
            }
        }
        
        rootNode.addChildNode(helixNodes)
        rootNode.addChildNode(sheetsNodes)
        rootNode.addChildNode(otherNodes)
    }
    
    public func atomNodes(atoms: [Atom], to rootNode: SCNNode, forResidue: Int? = nil, hidden: Bool = true) {
        
        let resNumber = forResidue ?? 0 // If residue number its not specified assume it does not velong to any residue (see atom numbering for reference at the bottom of this file)
        
        //DispatchQueue.global(qos: .userInitiated).async { [self] in
            for atom in atoms {
                let atomNode = SCNNode()
                atomNode.position = atom.position
                atomNode.isHidden = hidden
                atomNode.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
                atomNode.geometry = atomGeometries.atoms[atom.type]
                atomNode.constraints = [SCNBillboardConstraint()]
                atomNode.name = "A_\(atom.type.rawValue)_\(atom.number)_\(resNumber)"
                rootNode.addChildNode(atomNode)
            }
        //}
    }
    
}

//MARK: Node geometries
/// Geometries for SceneKit nodes. These geometries implement the default materials.
public class AtomGeometries {
    
    /// A SCNSphere (type of geometry) is assigned to each atom with its corresponding SCNMateria from ColorSettingsl.bondMaterial
    public var atoms: [Element : SCNSphere]!
    
    /// A SCNCylinder (type of geometry) is assigned to the bond with its corresponding SCNMaterial from ColorSettings.atomColors
    public var bond: SCNCylinder!
    
    let colors: ProteinColors
    
    public init(colors: ProteinColors) {
        self.colors = colors
        atoms = setupAtomGeometries()
        bond = setupBondGeometries()
    }
    
    /// Inits the atoms property with default values for the geometries
    private func setupAtomGeometries() -> [Element : SCNSphere] {
        
        let materials = colors.atomMaterials!
        
        var atoms: [Element : SCNSphere] = [:]
        
        for element in Element.allCases {
            let sphere = SCNSphere()
            sphere.radius = element.radius
            sphere.materials = [materials[element]!]
            atoms[element] = sphere
        }
        
        return atoms
    }
    
    private func setupBondGeometries() -> SCNCylinder {
        let material = colors.bondMaterial!
        let cylinder = SCNCylinder()
        cylinder.radius = 0.1
        cylinder.materials = [material]
        
        return cylinder
    }
}

//MARK: Color settings
/// Colors of atoms, bonds, and other properties of the SceneKit scene. This class is meant to reside in GlobalSettings as a property.
public final class ProteinColors: ObservableObject {
    
    /// Background color of the SceneKit view
    @Published public var backgroundColor: Color = .white
    
    /// Core material. For changing roughness, shinnies...
    public var coreMaterial: SCNMaterial!
    
    //MARK: Bonds
    /// The color of the bond. Default: .gray
    @Published public var bondColor: Color = .gray {
        didSet {
            updateBondNodeMaterial()
        }
    }
    
    /// The material of the bond, defaulted to coreMaterial
    public var bondMaterial: SCNMaterial!
    
    //MARK: Atoms
    /// Color of each atom. Array position represents the atomic number. For position 0, the default white value is set.
    @Published public var atomColors: [Color]!
    /// Materials for each atom. Default of coreMaterial + color of each atom
    public var atomMaterials: [Element : SCNMaterial]!
    
    public var selectionColor: Color = .blue {
        didSet {
            updateSelectionMaterial()
        }
    }
    public var selectionMaterial: SCNMaterial!
    
    //Backbone                  |
    //                          |
    //Cartoon helix             | TODO: implement
    //                          |
    //Cartoon beta sheets       |
    
    @Published public var metalness: Float = 0.35 {
        didSet {
            updateMetalness()
        }
    } // How shiny the material is
    @Published public var roughness: Float = 0.40 {
        didSet {
            updateRoughness()
        }
    } // How rough the material is
    
    public init() {
        self.coreMaterial = setupCoreMaterial()
        self.bondMaterial = setupBondMaterial()
        (self.atomColors, self.atomMaterials) = setupAtomMaterials()
        self.selectionMaterial = setupSelectionMaterial()
    }
    
    /// Sets the core material to the default values and inits the property
    private func setupCoreMaterial() -> SCNMaterial {
        let material = SCNMaterial()
        material.diffuse.contents = UColor.gray // Default coreMaterial color is equal to the bond color
        material.lightingModel = .physicallyBased
        material.metalness.contents = metalness
        material.roughness.contents = roughness
        
        return material
    }
    
    /// Sets the atom materials  and colors to the default values and inits the property
    private func setupAtomMaterials() -> ([Color], [Element : SCNMaterial]) {
        
        var atomColors: [Color] = []
        var atomMaterials: [Element : SCNMaterial] = [:]
        
        //First color "0 index" white, the rest of the indexes correpsond with the atomic number
        atomColors.append(.white)
        
        for atom in Element.allCases {
            atomColors.append(atom.color)
            let aMaterial = coreMaterial!.copy() as! SCNMaterial
            aMaterial.diffuse.contents = atom.color.uColor
            atomMaterials[atom] = aMaterial
        }
        return (atomColors, atomMaterials)
    }
    
    /// Sets the bond material equal to the coreMaterial
    private func setupBondMaterial() -> SCNMaterial {
        let bondMaterial = coreMaterial!.copy() as! SCNMaterial
        bondMaterial.diffuse.contents = bondColor.uColor
        
        return bondMaterial
    }
    
    private func setupSelectionMaterial() -> SCNMaterial {
        let selectionMaterial = SCNMaterial()
        selectionMaterial.diffuse.contents = selectionColor.uColor
        return selectionMaterial
    }
    
    /// SwiftUI color picker changes a Color type. After the color is set, the material corresponding to the atom has to be updated with the new color
    /// - Parameter element: Element of which the color changed
    public func updateNodeAtomMaterial(_ element: Element) {
        atomMaterials[element]!.diffuse.contents = atomColors[element.atomicNumber].uColor // Force unwrap as the element should exist
    }
    /// SwiftUI color picker changes a Color type. After the color is set, the material corresponding to the bond has to be updated with the new color
    private func updateBondNodeMaterial() {
        bondMaterial.diffuse.contents = bondColor.uColor
    }
    
    private func updateSelectionMaterial() {
        selectionMaterial.diffuse.contents = selectionColor.uColor
    }
    
    private func updateMetalness() {
        bondMaterial.metalness.contents = metalness
        selectionMaterial.metalness.contents = metalness
        for material in atomMaterials.values {
            material.metalness.contents = metalness
        }
    }
    
    private func updateRoughness() {
        bondMaterial.roughness.contents = roughness
        selectionMaterial.roughness.contents = roughness
        for material in atomMaterials.values {
            material.roughness.contents = roughness
        }
    }
    
    //MARK: Charts
    
    @Published public var chartColor: Color = .blue
    
}
