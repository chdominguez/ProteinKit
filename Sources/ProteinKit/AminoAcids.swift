//
//  Created by Christian Dominguez on 22/4/22.
//

import Foundation

// Value type which contains the residue name, the structure, phi, psi angles,the area and the atoms forming the residue.
public struct Residue {
    // Default values:
    public let type: AminoAcid
    public let structure: SecondaryStructure
    public let phi: Float
    public let psi: Float
    public let area: Float
    public let atoms: [Atom]
}

// An enum that defines AminoAcids and its properties
public enum AminoAcid: CaseIterable {
    
    case ala
    case gly
    case ile
    case leu
    case pro
    case val
    case phe
    case trp
    case tyr
    case asp
    case glu
    case arg
    case his
    case lys
    case ser
    case thr
    case cys
    case met
    case asn
    case gln
    case cyx // CYM for cysteine residues involved in disulphide bridge
    case cym // Deprotonated cys
    case hid // Histidine with hydrogen on the delta nitrogen
    case hie // Histidine with hydrogen on the epsilon nitrogen
    case hip // Histidine with hydrogens on both nitrogens; this is positively charged.
    case glh // Glutamic acid neutral form
    case ash // Neutral form of ASP
    
    /// Full name of the amino acid (i.e. Alanine)
    var name: String {
        switch self {
        case .ala:
            return "Alanine"
        case .gly:
            return "Glycine"
        case .ile:
            return "Isoleucine"
        case .leu:
            return "Leucine"
        case .pro:
            return "Proline"
        case .val:
            return "Valine"
        case .phe:
            return "Phenylalanine"
        case .trp:
            return "Tryptophan"
        case .tyr:
            return "Tyrosine"
        case .asp:
            return "Aspartic Acid"
        case .glu:
            return "Glutamic Acid"
        case .arg:
            return "Arginine"
        case .his:
            return "Histidine"
        case .lys:
            return "Lysine"
        case .ser:
            return "Serine"
        case .thr:
            return "Threonine"
        case .cys:
            return "Cysteine"
        case .met:
            return "Methionine"
        case .asn:
            return "Asparagine"
        case .gln:
            return "Glutamine"
        case .cyx:
            return "Cysteine"
        case .cym:
            return "Cysteine"
        case .hid:
            return "Histidine"
        case .hie:
            return "Histidine"
        case .hip:
            return "Histidine"
        case .glh:
            return "Glutamic Acid"
        case .ash:
            return "Aspartic Acid"
        }
    }
    
    /// One letter symbol (i.e. A)
    var symbol: String {
        switch self {
        case .ala:
            return "A"
        case .gly:
            return "G"
        case .ile:
            return "I"
        case .leu:
            return "L"
        case .pro:
            return "P"
        case .val:
            return "V"
        case .phe:
            return "F"
        case .trp:
            return "W"
        case .tyr:
            return "Y"
        case .asp:
            return "D"
        case .glu:
            return "E"
        case .arg:
            return "R"
        case .his:
            return "H"
        case .lys:
            return "K"
        case .ser:
            return "S"
        case .thr:
            return "T"
        case .cys:
            return "C"
        case .met:
            return "M"
        case .asn:
            return "N"
        case .gln:
            return "Q"
        case .cyx:
            return "C"
        case .cym:
            return "C"
        case .hid:
            return "H"
        case .hie:
            return "H"
        case .hip:
            return "H"
        case .glh:
            return "E"
        case .ash:
            return "D"
        }
    }
    
    /// Three letter symbol (i.e. Ala)
    var code: String {
        switch self {
        case .ala:
            return "Ala"
        case .gly:
            return "Gly"
        case .ile:
            return "Ile"
        case .leu:
            return "Leu"
        case .pro:
            return "Pro"
        case .val:
            return "Val"
        case .phe:
            return "Phe"
        case .trp:
            return "Trp"
        case .tyr:
            return "Tyr"
        case .asp:
            return "Asp"
        case .glu:
            return "Glu"
        case .arg:
            return "Arg"
        case .his:
            return "His"
        case .lys:
            return "Lys"
        case .ser:
            return "Ser"
        case .thr:
            return "Thr"
        case .cys:
            return "Cys"
        case .met:
            return "Met"
        case .asn:
            return "Asn"
        case .gln:
            return "Gln"
        case .cyx:
            return "Cyx"
        case .cym:
            return "Cym"
        case .hid:
            return "Hid"
        case .hie:
            return "Hie"
        case .hip:
            return "Hip"
        case .glh:
            return "Glh"
        case .ash:
            return "Ash"
        }
    }
    
}

// An enum that defines secondary protein structures
public enum SecondaryStructure: String, CaseIterable {
    case alphaHelix = "H"
    case helix310 = "G"
    case phiHelix = "I"
    
    /// Also known as beta-sheets
    case strand = "E"
    
    case bridge = "B"
    case coil = "C"
    case turnI = "1"
    case turnIp = "2"
    case turnII = "3"
    case turnIIp = "4"
    case turnVIa = "5"
    case turnVIb = "6"
    case turnVIII = "7"
    case turnIV = "8"
    case GammaClassic = "@"
    case GammaInv = "&"
    case turn = "T"
    
    var priority: Int {
        switch self {
        case .coil, .turn, .turnI, .turnIp, .turnII, .turnIIp, .turnIV, .turnVIa, .turnVIb, .turnVIII:
            return 1
        case .alphaHelix, .helix310, .phiHelix:
            return 2
        case .strand, .bridge:
            return 3
        default:
            return 4
        }
    }
    
}
