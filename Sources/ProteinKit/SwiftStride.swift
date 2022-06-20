import Foundation
import CStride
import SceneKitPlus

// Handles reading files and performing the stride algorithm
public class Stride {
    
    public init() { }
    
    /// Runs Stride with the given file and returns an array of Residues containing the information of the secondary structure
    /// - Parameters:
    ///   - file: The path to the file
    ///   - arguments: Optional Stride arguments:
    ///     -fFile           Output file
    ///     -mFile         MolScript file
    ///     -o Report    Secondary structure summary only
    ///     -h Report    Hydrogen bonds
    ///     -rId1Id2...    Read only chains Id1, Id2 ...
    ///     -cId1Id2...   Process only Chains Id1, Id2 ...
    ///     -q[File]     Generate SeQuence file in FASTA format and close the program
    ///     -fFile           Output file
    public static func predict(from file: String, arguments arg: [String]? = nil, showReport: Bool = false) -> [Residue]? {
        
        var result: RChain? = nil
        
        var arguments = ["main", file] /// Basic compulsory arguments to run the program
        
        // Appends the optional arguments to the main arg array with all the arguments
        if let arg = arg {
            arg.forEach { a in
                arguments.append(a)
            }
        }
        
        var cArgs = arguments.map {strdup($0)}
        
        if showReport {
            result = stride(Int32(arguments.count), &cArgs, 1)
        } else {
            result = stride(Int32(arguments.count), &cArgs, 0)
        }

        // Deallocate arguments
        for ptr in cArgs {
            ptr?.deallocate()
        }
        
        // Process the aminoacids and return the value
        
        guard let _ = result else {
            return nil
        }

        
        let aminos = processResult(result: result!)
        
        // Frees the memory
        result!.chain.deallocate()
        
        result = nil
        
        return aminos
    }

    private static func processResult(result: RChain) -> [Residue]? {
        
        var residues: [Residue] = []
        
        for n in 0..<result.NChain {
            let c = result.chain[Int(n)]!.pointee
            for i in 0..<c.NRes {
                
                let cResidue = c.Rsd[Int(i)]!
                
                guard let type = getAA(from: unsafePointerToString(value: cResidue.pointee.ResType)) else {return nil}
                
                guard let structure = getStructure(from: unsafePointerToString(value: cResidue.pointee.Prop.pointee.Asn)) else {return nil}
                
                let phi = cResidue.pointee.Prop.pointee.Phi
                
                let psi = cResidue.pointee.Prop.pointee.Psi
                
                let area = cResidue.pointee.Prop.pointee.Solv
                
                let atoms: [Atom] = getAtoms(fromCres: cResidue)
                
                let newResidue = Residue(type: type, structure: structure, phi: phi, psi: psi, area: area, atoms: atoms)
                
                cResidue.deallocate() // Frees the memory
                
                residues.append(newResidue)
                
            }
        }
        
        return residues
    }
    
    private static func getAA(from code: String) -> AminoAcid? {
        for aa in AminoAcid.allCases {
            if aa.code.uppercased() == code { return aa }
        }
        return nil
    }
    
    private static func getStructure(from code: String) -> SecondaryStructure? {
        guard let l = code.first else {return nil}
        for structure in SecondaryStructure.allCases {
            if String(l) == structure.rawValue {return structure}
        }
        return nil
    }
        
}



/// Transform an unsafe pointer a.k.a a tuple of Chars (Int8, Int8, ...) to a Swift string
private func unsafePointerToString<T>(value: T) -> String {
    return withUnsafePointer(to: value) { ptr in
        ptr.withMemoryRebound(to: UInt8.self, capacity: MemoryLayout.size(ofValue: ptr)) {String(cString: $0)}
    }
}



private func getAtoms(fromCres r: UnsafeMutablePointer<RESIDUE>) -> [Atom] {
    
    var atomsResult: [Atom] = []
    
    let coords = Mirror(reflecting: r.pointee.Coord).children.map({$0.value as! (Float,Float,Float)})
    let atoms = Mirror(reflecting: r.pointee.AtomType).children.map({$0.value})
    
    for (i,atom) in atoms.enumerated() {
        
        let atomInfo = unsafePointerToString(value: atom)
        if atomInfo.isEmpty || atomInfo == "H" {break}
        
        guard let at = getAtom(fromString: atomInfo, isPDB: true) else {continue}
        let x = UFloat(coords[i].0)
        let y = UFloat(coords[i].1)
        let z = UFloat(coords[i].2)
        
        atomsResult.append(Atom(position: SCNVector3Make(x, y, z), type: at, number: i, info: atomInfo))
        
        
    }
    
    return atomsResult
    
}

