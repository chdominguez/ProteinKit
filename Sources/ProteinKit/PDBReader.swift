//
//  File.swift
//  
//
//  Created by Christian Dominguez on 10/6/22.
//

import SceneKitPlus
import Combine

public class PDBReader {
    public init() { }
    
    public var steps: [Step] = []
    
    private var errorLine: Int = 0
    
    // Some pdbs have variable column size, with data placed in different columns
    var nindex = 0 // Number of columns
    
    // Keep track of the number of atoms
    var natoms = 0
    
    // Variable to save current step atom positions
    let currentMolecule = Molecule()
    
    // Backbone atoms
    let backBone = Molecule()
    
    public func readPDB(from fileURL: URL) throws {
        guard fileURL.startAccessingSecurityScopedResource() else {throw ProteinKitError.noAccess}
        let splitFile = try! String(contentsOf: fileURL).split(separator: "\n")
        
        // Assign the PDB error for cleaner code
        //let pdbError = AtomicErrors.pdbError
        
        for line in splitFile {
            try processLine(String(line))
        }
        
        // Create the step corresponding to this protein
        let step = Step()
        step.molecule = currentMolecule
        step.isFinalStep = true
        step.isProtein = true
        step.backBone = backBone
        
        // Run the Stride algorithm to obtain secondary structure
        guard let aminos = Stride.predict(from: fileURL.path) else {throw ProteinKitError.PDBError}
        
        step.res = aminos
        
//        for i in step.res.indices {
//            step.res
//            step.res[i].atoms = step.molecule.
//        }
        
        self.steps.append(step)
    }
    
    private func processLine(_ line: String) throws {
        //Increment current line by 1 to keep track if an error happens
        errorLine += 1
#warning("return errorLine")
        
        let splitted = line.split(separator: " ")
#warning("TODO: Hide / unhide solvent")
        
        if splitted.contains("TER") || splitted.contains("WAT") {
            // PROCESS SOLVENT
            return
        }
        
#warning("TODO: PDB helix, residues, solvent...")
        // Temporal implementation of PDB files.
        switch splitted.first {
            //MARK: ATOM
        case "ATOM":
            do {
                //Increment number of atoms
                natoms += 1
                // First check number of columns to see if it's a compatible PDB
                if nindex == 0 {
                    for (i,n) in splitted.enumerated() {
                        nindex = i
                        guard let dbl = Double(n) else {continue}
                        if floor(dbl) != dbl {
                            break
                        }
                        
                    }
                }
                let atomString = String(splitted[2])
                guard let element = getAtom(fromString: atomString, isPDB: true), let x = Float(splitted[nindex]), let y = Float(splitted[nindex + 1]), let z = Float(splitted[nindex + 2]) else {throw ProteinKitError.PDBError}
                
                let position = SCNVector3(x, y, z)
                
                var atom = Atom(position: position, type: element, number: natoms)
                
                atom.info = atomString
                
                switch atomString {
                case "N", "C", "CA", "O": // Save backbone nitrogens, alpha carbons and peptide bonded carbons
                    backBone.atoms.append(atom)
                default: ()
                }
                
                currentMolecule.atoms.append(atom)
                
            }
            //            case "HELIX":
            //                do {
            //                    structures.append(.alphaHelix)
            //                    let from = Int(splitted[5])!
            //                    let to = Int(splitted[8])!
            //                    structuresFromTo.append((from,to))
            //                }
            //            case "SHEET":
            //                do {
            //                    structures.append(.strand)
            //                    let from = Int(splitted[6])!
            //                    let to = Int(splitted[9])!
            //                    structuresFromTo.append((from,to))
            //                }
        default: return
        }
    }
    
}
