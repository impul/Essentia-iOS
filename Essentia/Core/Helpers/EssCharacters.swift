//
//  EssCharacters.swift
//  Essentia
//
//  Created by Pavlo Boiko on 11/2/18.
//  Copyright © 2018 Essentia-One. All rights reserved.
//

import Foundation

public enum EssCharacters: String {
    case latin = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ "
    case latinUppercased = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    case digits = "1234567890"
    case special = "-/:;()₴&@\".,?!‘[]{}#%^+*=•£$€><~|\\_.,?!‘–—•§₽¥€¢£₩«»„“”…¿¡’‘`‰"
    case ammountSeparators = ",."
    
    public var set: CharacterSet {
        return CharacterSet(charactersIn: rawValue)
    }
    
    public static func combinedSet(from characters: [EssCharacters]) -> CharacterSet {
        var set = CharacterSet()
        characters.forEach { (character) in
            set = set.union(character.set)
        }
        return set
    }
}

public extension String {
    public func coincidencesIndexes(with set: CharacterSet) -> [Int] {
        return self.enumerated().compactMap { (index, character) -> Int? in
            let setContainCharacter = set.isSuperset(of: CharacterSet(charactersIn: String(character)))
            return setContainCharacter ?! index
        }
    }
    
    public func onlyContain(characters: CharacterSet) -> Bool {
        return characters.isSuperset(of: CharacterSet(charactersIn: self))
    }
}
