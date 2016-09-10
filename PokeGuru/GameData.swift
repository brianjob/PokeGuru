//
//  GameData.swift
//  PokeGuru
//
//  Created by Brian Barton on 9/6/16.
//  Copyright © 2016 Brian Barton. All rights reserved.
//

import Foundation

public struct GameDataPokemon: Equatable {
    public let id: Int
    public let name: String
    public let types: [GameDataType]
    public let baseStamina: Int
    public let baseAttack: Int
    public let baseDefense: Int
    public let maxCP: Double
    public let height: Double
    public let weight: Double
    public let heightStdDev: Double
    public let weightStdDev: Double
    public let baseCaptureRate: Double
    public let baseFleeRate: Double
    public let collisionRadius: Double
    public let collisionHeight: Double
    public let collisionHeadRadius: Double
    public let movementType: String
    public let movementTimer: Int
    public let jumpTime: Double
    public let attackTimer: Int
    public let quickMoves: [GameDataMove]
    public let cinematicMoves: [GameDataMove]
    public let animationTime: [Double]
    public let evolution: Int?
    public let evolutionPips: String
    public let pokemonClass: Int
    public let familyId: Int
    public let candyToEvolve: Int
}

public func ==(lhs: GameDataPokemon, rhs: GameDataPokemon) -> Bool {
    return lhs.id == rhs.id
}

public struct GameDataMove: Equatable {
    private let EFFECTIVE_MODIFIER = 1.25
    private let NOT_EFFECTIVE_MODIFIER = 0.8
    private let NO_EFFECT_MODIFIER = 0.8
    
    public let id: Int
    public let name: String
    public let moveType: String
    public let animationId: Int
    public let type: GameDataType
    public let power: Int
    public let accuracyChance: Double
    public let staminaLossScalar: Double
    public let trainerLevelMin: Double
    public let trainerLevelMax: Double
    public let duration: Int
    public let damageWindowStart: Int
    public let damageWindowEnd: Int
    public let energyDelta: Int
    public let criticalChance: Double
    
    // returns the type modifier of a move against a given defender
    public func calcTypeModifier(defender: GameDataPokemon) -> Double {
        var typeModifier = 1.0
        
        for type in defender.types {
            if self.type.effective.contains(type.id) {
                typeModifier *= EFFECTIVE_MODIFIER
            }
            if self.type.notEffective.contains(type.id) {
                typeModifier *= NOT_EFFECTIVE_MODIFIER
            }
            if self.type.noEffect.contains(type.id) {
                typeModifier *= NO_EFFECT_MODIFIER
            }
        }
        
        return typeModifier
    }
}

public func ==(lhs: GameDataMove, rhs: GameDataMove) -> Bool {
    return lhs.id == rhs.id
}

public struct GameDataType: Hashable {
    public let id: Int
    public let name: String
    public let effective: [Int]
    public let notEffective: [Int]
    public let noEffect: [Int]
    
    public var hashValue: Int { get { return id } }
}

public func ==(lhs: GameDataType, rhs: GameDataType) -> Bool {
    return lhs.id == rhs.id
}