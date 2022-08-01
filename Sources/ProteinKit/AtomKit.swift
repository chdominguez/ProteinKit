//
//  AtomModel.swift
//  AtomModel
//
//  Created by Christian Dominguez on 20/8/21.
//

import SwiftUI
import SceneKit

public struct Atom: Identifiable {
    
    public init(position: SCNVector3, type: Element, number: Int, info: String = "") {
        
        self.position = position
        self.type = type
        self.number = number
        self.info = info
        
    }
    
    public let id = UUID()
    
    public var position: SCNVector3
    public var type: Element
    public var number: Int
  
    public var info: String // Allows for further classification. For example: "CA", which denotes an alpha carbon in PDBs.
}

/// Returns the Element of the given String with an atomic symbol or the atomic number
/// - Parameter string: String containing atomic symbol or number (i.e 'H' or '1' for Hydrogen)
/// - Returns: Element matching atomic symbol or number
internal func getAtom(fromString string: String, isPDB: Bool = false) -> Element? {
    if isPDB {
        return Element.allCases.first(where: {$0.rawValue == string.prefix(1)})
    }
    else {
        if let atomicNumber = Int(string) {
            return Element.allCases[atomicNumber - 1]
        } else {
            return Element.allCases.first(where: {$0.rawValue == string})
        }
    }
}

/// Molecule class. Contains an array of atoms as its single property
public class Molecule {
    
    public init() {}
    
    public var atoms: [Atom] = []
}

public struct CartoonPositions {
    
    public init() {}
    
    public var positions: [SCNVector3] = []
    public var structure: SecondaryStructure = .alphaHelix
}

/// Step class. Describes any molecular scene possible. Contains different optional variables depending on which
/// type of file has been opened. It has support for accomodating multiple job types like:
/// Gaussian - energy, isFinalStep, jobNumber, isInput
/// XYZ - timestep
public class Step {
    
    public init() {}
    
    /// The step number of the job (for example in optimization calculations)
    public var stepNumber: Int?
    
    /// The molecule of this step. Contains the atom positions.
    public var molecule: Molecule?
    
    /// Keeping track if its a step from an input file
    public var isInput: Bool?
    
    /// The energy of the system at this step
    public var energy: Double?
    
    /// Atom vibrations calculation jobs
    public var frequencys: [Double]?
    
    /// If the calculation ended with normal termination, set to true to the last step.
    public var isFinalStep: Bool = false
    
    /// For packages that support multiple jobs on the same calculation i.e Gaussian's --link1--
    public var jobNumber: Int = 1
    
    /// For MD calculations, the time of this step.
    public var timestep: Int?
    
    /// For PDBs. Tells the renderer if the step contains a protein
    public var isProtein: Bool = false
    
    /// For PDBs. Rendering the backbone only implies rendering these atoms
    public var backBone: Molecule?
    
    /// Residues present in this step
    public var res: [Residue] = []
}

public struct Frequencies {
    var freq: Double?
    var infrared: Double?
    var raman: Double?
}

#warning("TODO: Implement different bond types")
public enum bondTypes {
    case single
    case double
    case triple
    case resonant
}

public enum AtomStyle: String, CaseIterable {
    case ballAndStick = "Ball and Stick"
    case vanderwaals = "Van der Waals"
    case backBone = "Backbone"
    case cartoon = "Cartoon"
}

//  PeriodicTable

public enum Element: String, CaseIterable {
    
    case hydrogen       = "H"
    case helium         = "He"
    case lithium        = "Li"
    case beryllium      = "Be"
    case boron          = "B"
    case carbon         = "C"
    case nitrogen       = "N"
    case oxygen         = "O"
    case fluorine       = "F"
    case neon           = "Ne"
    case sodium         = "Na"
    case magnesium      = "Mg"
    case aluminium      = "Al"
    case silicon        = "Si"
    case phosphorus     = "P"
    case sulphur        = "S"
    case chlorine       = "Cl"
    case argon          = "Ar"
    case potassium      = "K"
    case calcium        = "Ca"
    case scandium       = "Sc"
    case titanium       = "Ti"
    case vanadium       = "V"
    case chromium       = "Cr"
    case manganese      = "Mn"
    case iron           = "Fe"
    case cobalt         = "Co"
    case nickel         = "Ni"
    case copper         = "Cu"
    case zinc           = "Zn"
    case gallium        = "Ga"
    case germanium      = "Ge"
    case arsenic        = "As"
    case selenium       = "Se"
    case bromine        = "Br"
    case krypton        = "Kr"
    case rubidium       = "Rb"
    case strontium      = "Sr"
    case yttrium        = "Y"
    case zirconium      = "Zr"
    case niobium        = "Nb"
    case molybdenum     = "Mo"
    case technecium     = "Tc"
    case ruthenium      = "Ru"
    case rhodium        = "Rh"
    case palladium      = "Pd"
    case silver         = "Ag"
    case cadmium        = "Cd"
    case indium         = "In"
    case tin            = "Sn"
    case antimony       = "Sb"
    case tellurium      = "Te"
    case iodine         = "I"
    case xenon          = "Xe"
    case caesium        = "Cs"
    case barium         = "Ba"
    case lanthanum      = "La"
    case cerium         = "Ce"
    case praseodymium   = "Pr"
    case neodymium      = "Nd"
    case promethium     = "Pm"
    case samarium       = "Sm"
    case europium       = "Eu"
    case gadolinium     = "Gd"
    case terbium        = "Tb"
    case dysprosium     = "Dy"
    case holmium        = "Ho"
    case erbium         = "Er"
    case thulium        = "Tm"
    case ytterbium      = "Yb"
    case lutetium       = "Lu"
    case hafnium        = "Hf"
    case tantalum       = "Ta"
    case tungsten       = "W"
    case rhenium        = "Re"
    case osmium         = "Os"
    case iridium        = "Ir"
    case platinum       = "Pt"
    case gold           = "Au"
    case mercury        = "Hg"
    case thalium        = "Tl"
    case lead           = "Pb"
    case bismuth        = "Bi"
    case polonium       = "Po"
    case astatine       = "At"
    case radon          = "Rn"
    case francium       = "Fr"
    case radium         = "Ra"
    case actinium       = "Ac"
    case thorium        = "Th"
    case protoactinium  = "Pa"
    case uranium        = "U"
    case neptunium      = "Mp"
    case plutonium      = "Pu"
    case americium      = "Am"
    case curium         = "Cm"
    case berkelium      = "Bk"
    case californium    = "Cf"
    case einstenium     = "Es"
    case fermium        = "Fm"
    case mendelevium    = "Md"
    case nobelium       = "No"
    case lawrencium     = "Lr"
    case rutherfordium  = "Rf"
    case dubnium        = "Db"
    case seaborgium     = "Sg"
    case bohrium        = "Bh"
    case hassium        = "Hs"
    case meitnerium     = "Mt"
    case darmstadtium   = "Ds"
    case roentgenium    = "Rg"
    case copernicium    = "Cn"
    case nihonium       = "Nh"
    case flerovium      = "Fl"
    case moscovium      = "Mc"
    case livermorium    = "Lv"
    case tenessine      = "Ts"
    case oganesson      = "Og"
    case dummy          = "X"
    
    public var name: String {
        switch self {
        case .hydrogen:
            return "Hydrogen"
        case .helium:
            return "Helium"
        case .lithium:
            return "Lithium"
        case .beryllium:
            return "Beryllium"
        case .boron:
            return "Boron"
        case .carbon:
            return "Carbon"
        case .nitrogen:
            return "Nitrogen"
        case .oxygen:
            return "Oxygen"
        case .fluorine:
            return "Fluorine"
        case .neon:
            return "Neon"
        case .sodium:
            return "Sodium"
        case .magnesium:
            return "Magnesium"
        case .aluminium:
            return "Aluminium"
        case .silicon:
            return "Silicon"
        case .phosphorus:
            return "Phosphorus"
        case .sulphur:
            return "Sulfur"
        case .chlorine:
            return "Chlorine"
        case .argon:
            return "Argon"
        case .potassium:
            return "Potassium"
        case .calcium:
            return "Calcium"
        case .scandium:
            return "Scandium"
        case .titanium:
            return "Titanium"
        case .vanadium:
            return "Vanadium"
        case .chromium:
            return "Chromium"
        case .manganese:
            return "Manganese"
        case .iron:
            return "Iron"
        case .cobalt:
            return "Cobalt"
        case .nickel:
            return "Nickel"
        case .copper:
            return "Copper"
        case .zinc:
            return "Zinc"
        case .gallium:
            return "Gallium"
        case .germanium:
            return "Germanium"
        case .arsenic:
            return "Arsenic"
        case .selenium:
            return "Selenium"
        case .bromine:
            return "Bromine"
        case .krypton:
            return "Krypton"
        case .rubidium:
            return "Rubidium"
        case .strontium:
            return "Strontium"
        case .yttrium:
            return "Yttrium"
        case .zirconium:
            return "Zirconium"
        case .niobium:
            return "Niobium"
        case .molybdenum:
            return "Molybdenum"
        case .technecium:
            return "Technecium"
        case .ruthenium:
            return "Ruthenium"
        case .rhodium:
            return "Rhodium"
        case .palladium:
            return "Palladium"
        case .silver:
            return "Silver"
        case .cadmium:
            return "Cadmium"
        case .indium:
            return "Indium"
        case .tin:
            return "Tin"
        case .antimony:
            return "Antimony"
        case .tellurium:
            return "Tellurium"
        case .iodine:
            return "Iodine"
        case .xenon:
            return "Xenon"
        case .caesium:
            return "Caesium"
        case .barium:
            return "Barium"
        case .lanthanum:
            return "Lanthanum"
        case .cerium:
            return "Cerium"
        case .praseodymium:
            return "Praseodymium"
        case .neodymium:
            return "Neodymium"
        case .promethium:
            return "Promethium"
        case .samarium:
            return "Samarium"
        case .europium:
            return "Europium"
        case .gadolinium:
            return "Gadolinium"
        case .terbium:
            return "Terbium"
        case .dysprosium:
            return "Dysprosium"
        case .holmium:
            return "Holmium"
        case .erbium:
            return "Erbium"
        case .thulium:
            return "Thulium"
        case .ytterbium:
            return "Ytterbium"
        case .lutetium:
            return "Lutetium"
        case .hafnium:
            return "Hafnium"
        case .tantalum:
            return "Tantalum"
        case .tungsten:
            return "Tungsten"
        case .rhenium:
            return "Rhenium"
        case .osmium:
            return "Osmium"
        case .iridium:
            return "Iridium"
        case .platinum:
            return "Platinum"
        case .gold:
            return "Gold"
        case .mercury:
            return "Mercury"
        case .thalium:
            return "Thalium"
        case .lead:
            return "Lead"
        case .bismuth:
            return "Bismuth"
        case .polonium:
            return "Polonium"
        case .astatine:
            return "Astatine"
        case .radon:
            return "Radon"
        case .francium:
            return "Francium"
        case .radium:
            return "Radium"
        case .actinium:
            return "Actinium"
        case .thorium:
            return "Thorium"
        case .protoactinium:
            return "Protoactinium"
        case .uranium:
            return "Uranium"
        case .neptunium:
            return "Neptunium"
        case .plutonium:
            return "Plutonium"
        case .americium:
            return "Americium"
        case .curium:
            return "Curium"
        case .berkelium:
            return "Berkelium"
        case .californium:
            return "Californium"
        case .einstenium:
            return "Einstenium"
        case .fermium:
            return "Fermium"
        case .mendelevium:
            return "Mendelevium"
        case .nobelium:
            return "Nobelium"
        case .lawrencium:
            return "Lawrencium"
        case .rutherfordium:
            return "Rutherfordium"
        case .dubnium:
            return "Dubnium"
        case .seaborgium:
            return "Seaborgium"
        case .bohrium:
            return "Bohrium"
        case .hassium:
            return "Hassium"
        case .meitnerium:
            return "Meitnerium"
        case .darmstadtium:
            return "Darmstadtium"
        case .roentgenium:
            return "Roentgenium"
        case .copernicium:
            return "Copernicium"
        case .nihonium:
            return "Nihonium"
        case .flerovium:
            return "Flerovium"
        case .moscovium:
            return "Moscovium"
        case .livermorium:
            return "Livermorium"
        case .tenessine:
            return "Tenessine"
        case .oganesson:
            return "Oganesson"
        case .dummy:
            return "Dummy atom"
        }
    }
    
    // Default atom colors
    public  var color: Color {
        switch self {
          case .hydrogen:
              return .white  
          //case .deuterium:
              //return Color(red: 255/255, green: 255/255, blue: 192/255)
          //case .tritium:
              //return Color(red: 255/255, green: 255/255, blue: 192/255)
          case .helium:
              return Color(red: 217/255, green: 255/255, blue: 255/255)
          case .lithium:
              return Color(red: 204/255, green: 128/255, blue: 255/255)
          case .beryllium:
              return Color(red: 194/255, green: 255/255, blue: 0/255)
          case .boron:
              return Color(red: 255/255, green: 181/255, blue: 181/255)
          case .carbon:
              return Color(red: 144/255, green: 144/255, blue: 144/255)
          //case .carbon13:
              //return Color(red: 80/255, green: 80/255, blue: 80/255)
          //case .carbon14:
              //return Color(red: 64/255, green: 64/255, blue: 64/255)
          case .nitrogen:
              return Color(red: 48/255, green: 80/255, blue: 248/255)
          //case .nitrogen15:
              //return Color(red: 16/255, green: 80/255, blue: 80/255)
          case .oxygen:
              return Color(red: 255/255, green: 13/255, blue: 13/255)
          case .fluorine:
              return Color(red: 144/255, green: 224/255, blue: 80/255)
          case .neon:
              return Color(red: 179/255, green: 227/255, blue: 245/255)
          case .sodium:
              return Color(red: 171/255, green: 92/255, blue: 242/255)
          case .magnesium:
              return Color(red: 138/255, green: 255/255, blue: 0/255)
          case .aluminium:
              return Color(red: 191/255, green: 166/255, blue: 166/255)
          case .silicon:
              return Color(red: 240/255, green: 200/255, blue: 160/255)
          case .phosphorus:
              return Color(red: 255/255, green: 128/255, blue: 0/255)
          case .sulphur:
              return Color(red: 255/255, green: 255/255, blue: 48/255)
          case .chlorine:
              return Color(red: 31/255, green: 240/255, blue: 31/255)
          case .argon:
              return Color(red: 128/255, green: 209/255, blue: 227/255)
          case .potassium:
              return Color(red: 143/255, green: 64/255, blue: 212/255)
          case .calcium:
              return Color(red: 61/255, green: 255/255, blue: 0/255)
          case .scandium:
              return Color(red: 230/255, green: 230/255, blue: 230/255)
          case .titanium:
              return Color(red: 191/255, green: 194/255, blue: 199/255)
          case .vanadium:
              return Color(red: 166/255, green: 166/255, blue: 171/255)
          case .chromium:
              return Color(red: 138/255, green: 153/255, blue: 199/255)
          case .manganese:
              return Color(red: 156/255, green: 122/255, blue: 199/255)
          case .iron:
              return Color(red: 224/255, green: 102/255, blue: 51/255)
          case .cobalt:
              return Color(red: 240/255, green: 144/255, blue: 160/255)
          case .nickel:
              return Color(red: 80/255, green: 208/255, blue: 80/255)
          case .copper:
              return Color(red: 200/255, green: 128/255, blue: 51/255)
          case .zinc:
              return Color(red: 125/255, green: 128/255, blue: 176/255)
          case .gallium:
              return Color(red: 194/255, green: 143/255, blue: 143/255)
          case .germanium:
              return Color(red: 102/255, green: 143/255, blue: 143/255)
          case .arsenic:
              return Color(red: 189/255, green: 128/255, blue: 227/255)
          case .selenium:
              return Color(red: 255/255, green: 161/255, blue: 0/255)
          case .bromine:
              return Color(red: 166/255, green: 41/255, blue: 41/255)
          case .krypton:
              return Color(red: 92/255, green: 184/255, blue: 209/255)
          case .rubidium:
              return Color(red: 112/255, green: 46/255, blue: 176/255)
          case .strontium:
              return Color(red: 0/255, green: 255/255, blue: 0/255)
          case .yttrium:
              return Color(red: 148/255, green: 255/255, blue: 255/255)
          case .zirconium:
              return Color(red: 148/255, green: 224/255, blue: 224/255)
          case .niobium:
              return Color(red: 155/255, green: 194/255, blue: 201/255)
          case .molybdenum:
              return Color(red: 84/255, green: 181/255, blue: 181/255)
          case .technecium:
              return Color(red: 59/255, green: 158/255, blue: 158/255)
          case .ruthenium:
              return Color(red: 36/255, green: 143/255, blue: 143/255)
          case .rhodium:
              return Color(red: 10/255, green: 125/255, blue: 140/255)
          case .palladium:
              return Color(red: 0/255, green: 105/255, blue: 133/255)
          case .silver:
              return Color(red: 192/255, green: 192/255, blue: 192/255)
          case .cadmium:
              return Color(red: 255/255, green: 217/255, blue: 143/255)
          case .indium:
              return Color(red: 166/255, green: 117/255, blue: 115/255)
          case .tin:
              return Color(red: 102/255, green: 128/255, blue: 128/255)
          case .antimony:
              return Color(red: 158/255, green: 99/255, blue: 181/255)
          case .tellurium:
              return Color(red: 212/255, green: 122/255, blue: 0/255)
          case .iodine:
              return Color(red: 148/255, green: 0/255, blue: 148/255)
          case .xenon:
              return Color(red: 66/255, green: 158/255, blue: 176/255)
          case .caesium:
              return Color(red: 87/255, green: 23/255, blue: 143/255)
          case .barium:
              return Color(red: 0/255, green: 201/255, blue: 0/255)
          case .lanthanum:
              return Color(red: 112/255, green: 212/255, blue: 255/255)
          case .cerium:
              return Color(red: 255/255, green: 255/255, blue: 199/255)
          case .praseodymium:
              return Color(red: 217/255, green: 255/255, blue: 199/255)
          case .neodymium:
              return Color(red: 199/255, green: 255/255, blue: 199/255)
          case .promethium:
              return Color(red: 163/255, green: 255/255, blue: 199/255)
          case .samarium:
              return Color(red: 143/255, green: 255/255, blue: 199/255)
          case .europium:
              return Color(red: 97/255, green: 255/255, blue: 199/255)
          case .gadolinium:
              return Color(red: 69/255, green: 255/255, blue: 199/255)
          case .terbium:
              return Color(red: 48/255, green: 255/255, blue: 199/255)
          case .dysprosium:
              return Color(red: 31/255, green: 255/255, blue: 199/255)
          case .holmium:
              return Color(red: 0/255, green: 255/255, blue: 156/255)
          case .erbium:
              return Color(red: 0/255, green: 230/255, blue: 117/255)
          case .thulium:
              return Color(red: 0/255, green: 212/255, blue: 82/255)
          case .ytterbium:
              return Color(red: 0/255, green: 191/255, blue: 56/255)
          case .lutetium:
              return Color(red: 0/255, green: 171/255, blue: 36/255)
          case .hafnium:
              return Color(red: 77/255, green: 194/255, blue: 255/255)
          case .tantalum:
              return Color(red: 77/255, green: 166/255, blue: 255/255)
          case .tungsten:
              return Color(red: 33/255, green: 148/255, blue: 214/255)
          case .rhenium:
              return Color(red: 38/255, green: 125/255, blue: 171/255)
          case .osmium:
              return Color(red: 38/255, green: 102/255, blue: 150/255)
          case .iridium:
              return Color(red: 23/255, green: 84/255, blue: 135/255)
          case .platinum:
              return Color(red: 208/255, green: 208/255, blue: 224/255)
          case .gold:
              return Color(red: 255/255, green: 209/255, blue: 35/255)
          case .mercury:
              return Color(red: 184/255, green: 184/255, blue: 208/255)
          case .thalium:
              return Color(red: 166/255, green: 84/255, blue: 77/255)
          case .lead:
              return Color(red: 87/255, green: 89/255, blue: 97/255)
          case .bismuth:
              return Color(red: 158/255, green: 79/255, blue: 181/255)
          case .polonium:
              return Color(red: 171/255, green: 92/255, blue: 0/255)
          case .astatine:
              return Color(red: 117/255, green: 79/255, blue: 69/255)
          case .radon:
              return Color(red: 66/255, green: 130/255, blue: 150/255)
          case .francium:
              return Color(red: 66/255, green: 0/255, blue: 102/255)
          case .actinium:
              return Color(red: 112/255, green: 171/255, blue: 250/255)
          case .thorium:
              return Color(red: 0/255, green: 186/255, blue: 255/255)
          case .protoactinium:
              return Color(red: 0/255, green: 161/255, blue: 255/255)
          case .uranium:
              return Color(red: 0/255, green: 143/255, blue: 255/255)
          case .neptunium:
              return Color(red: 0/255, green: 128/255, blue: 255/255)
          case .plutonium:
              return Color(red: 0/255, green: 107/255, blue: 255/255)
          case .americium:
              return Color(red: 84/255, green: 92/255, blue: 242/255)
          case .curium:
              return Color(red: 120/255, green: 92/255, blue: 227/255)
          case .berkelium:
              return Color(red: 138/255, green: 79/255, blue: 227/255)
          case .californium:
              return Color(red: 161/255, green: 54/255, blue: 212/255)
          case .einstenium:
              return Color(red: 179/255, green: 31/255, blue: 212/255)
          case .fermium:
              return Color(red: 179/255, green: 31/255, blue: 186/255)
          case .mendelevium:
              return Color(red: 179/255, green: 13/255, blue: 166/255)
          case .nobelium:
              return Color(red: 189/255, green: 13/255, blue: 135/255)
          case .lawrencium:
              return Color(red: 199/255, green: 0/255, blue: 102/255)
          case .rutherfordium:
              return Color(red: 204/255, green: 0/255, blue: 89/255)
          case .dubnium:
              return Color(red: 209/255, green: 0/255, blue: 79/255)
          case .seaborgium:
              return Color(red: 217/255, green: 0/255, blue: 69/255)
          case .bohrium:
              return Color(red: 224/255, green: 0/255, blue: 56/255)
          case .hassium:
              return Color(red: 230/255, green: 0/255, blue: 46/255)
          case .meitnerium:
              return Color(red: 235/255, green: 0/255, blue: 38/255)
          default:
              return .pink
        }
    }

// COVALENT RADIUS
    public var radius: CGFloat {
        switch self {
        case .hydrogen:
            return 0.32
        case .helium:
            return 0.37
        case .lithium:
            return 1.30
        case .beryllium:
            return 0.99
        case .boron:
            return 0.84
        case .carbon:
            return 0.75
        case .nitrogen:
            return 0.71
        case .oxygen:
            return 0.64
        case .fluorine:
            return 0.60
        case .neon:
            return 0.62
        case .sodium:
            return 1.60
        case .magnesium:
            return 1.40
        case .aluminium:
            return 1.24
        case .silicon:
            return 1.14
        case .phosphorus:
            return 1.09
        case .sulphur:
            return 1.04
        case .chlorine:
            return 1.00
        case .argon:
            return 1.01
        default:
            return 1.5
        }
    }

    public var atomicNumber: Int {
        switch self {
        case .hydrogen:
            return 1
        case .helium:
            return 2
        case .lithium:
            return 3
        case .beryllium:
            return 4
        case .boron:
            return 5
        case .carbon:
            return 6
        case .nitrogen:
            return 7
        case .oxygen:
            return 8
        case .fluorine:
            return 9
        case .neon:
            return 10
        case .sodium:
            return 11
        case .magnesium:
            return 12
        case .aluminium:
            return 13
        case .silicon:
            return 14
        case .phosphorus:
            return 15
        case .sulphur:
            return 16
        case .chlorine:
            return 17
        case .argon:
            return 18
        case .potassium:
            return 19
        case .calcium:
            return 20
        case .scandium:
            return 21
        case .titanium:
            return 22
        case .vanadium:
            return 23
        case .chromium:
            return 24
        case .manganese:
            return 25
        case .iron:
            return 26
        case .cobalt:
            return 27
        case .nickel:
            return 28
        case .copper:
            return 29
        case .zinc:
            return 30
        case .gallium:
            return 31
        case .germanium:
            return 32
        case .arsenic:
            return 33
        case .selenium:
            return 34
        case .bromine:
            return 35
        case .krypton:
            return 36
        case .rubidium:
            return 37
        case .strontium:
            return 38
        case .yttrium:
            return 39
        case .zirconium:
            return 40
        case .niobium:
            return 41
        case .molybdenum:
            return 42
        case .technecium:
            return 43
        case .ruthenium:
            return 44
        case .rhodium:
            return 45
        case .palladium:
            return 46
        case .silver:
            return 47
        case .cadmium:
            return 48
        case .indium:
            return 49
        case .tin:
            return 50
        case .antimony:
            return 51
        case .tellurium:
            return 52
        case .iodine:
            return 53
        case .xenon:
            return 54
        case .caesium:
            return 55
        case .barium:
            return 56
        case .lanthanum:
            return 57
        case .cerium:
            return 58
        case .praseodymium:
            return 59
        case .neodymium:
            return 60
        case .promethium:
            return 61
        case .samarium:
            return 62
        case .europium:
            return 63
        case .gadolinium:
            return 64
        case .terbium:
            return 65
        case .dysprosium:
            return 66
        case .holmium:
            return 67
        case .erbium:
            return 68
        case .thulium:
            return 69
        case .ytterbium:
            return 70
        case .lutetium:
            return 71
        case .hafnium:
            return 72
        case .tantalum:
            return 73
        case .tungsten:
            return 74
        case .rhenium:
            return 75
        case .osmium:
            return 76
        case .iridium:
            return 77
        case .platinum:
            return 78
        case .gold:
            return 79
        case .mercury:
            return 80
        case .thalium:
            return 81
        case .lead:
            return 82
        case .bismuth:
            return 83
        case .polonium:
            return 84
        case .astatine:
            return 85
        case .radon:
            return 86
        case .francium:
            return 87
        case .radium:
            return 88
        case .actinium:
            return 89
        case .thorium:
            return 90
        case .protoactinium:
            return 91
        case .uranium:
            return 92
        case .neptunium:
            return 93
        case .plutonium:
            return 94
        case .americium:
            return 95
        case .curium:
            return 96
        case .berkelium:
            return 97
        case .californium:
            return 98
        case .einstenium:
            return 99
        case .fermium:
            return 100
        case .mendelevium:
            return 101
        case .nobelium:
            return 102
        case .lawrencium:
            return 103
        case .rutherfordium:
            return 104
        case .dubnium:
            return 105
        case .seaborgium:
            return 106
        case .bohrium:
            return 107
        case .hassium:
            return 108
        case .meitnerium:
            return 109
        case .darmstadtium:
            return 110
        case .roentgenium:
            return 111
        case .copernicium:
            return 112
        case .nihonium:
            return 113
        case .flerovium:
            return 114
        case .moscovium:
            return 115
        case .livermorium:
            return 116
        case .tenessine:
            return 117
        case .oganesson:
            return 118
        case .dummy:
            return 119
        }
    }

    public var canDoubleBond: Bool { // Temporary
        switch self {
        case .hydrogen:
            return false
        case .helium:
            return false
        case .lithium:
            return false
        case .beryllium:
            return false
        case .boron:
            return false
        default:
            return true
        }
    }
}
