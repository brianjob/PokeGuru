//
//  GameData.swift
//  PokeGuru
//
//  Created by Brian Barton on 9/6/16.
//  Copyright © 2016 Brian Barton. All rights reserved.
//

import Foundation

public struct GameDataPokemon: Equatable {
    let id: Int
    let name: String
    let types: [GameDataType]
    let baseStamina: Int
    let baseAttack: Int
    let baseDefense: Int
    let maxCP: Double
    let height: Double
    let weight: Double
    let heightStdDev: Double
    let weightStdDev: Double
    let baseCaptureRate: Double
    let baseFleeRate: Double
    let collisionRadius: Double
    let collisionHeight: Double
    let collisionHeadRadius: Double
    let movementType: String
    let movementTimer: Int
    let jumpTime: Double
    let attackTimer: Int
    let quickMoves: [Int]
    let cinematicMoves: [Int]
    let animationTime: [Double]
    let evolution: Int?
    let evolutionPips: String
    let pokemonClass: Int
    let familyId: Int
    let candyToEvolve: Int
}

public func ==(lhs: GameDataPokemon, rhs: GameDataPokemon) -> Bool {
    return lhs.id == rhs.id
}

public struct GameDataMove: Equatable {
    let id: Int
    let name: String
    let moveType: String
    let animationId: Int
    let type: GameDataType
    let power: Int
    let accuracyChance: Double
    let staminaLossScalar: Double
    let trainerLevelMin: Double
    let trainerLevelMax: Double
    let duration: Int
    let damageWindowStart: Int
    let damageWindowEnd: Int
    let energyDelta: Int
    let criticalChance: Double
}

public func ==(lhs: GameDataMove, rhs: GameDataMove) -> Bool {
    return lhs.id == rhs.id
}

public struct GameDataType: Hashable {
    let id: Int
    let name: String
    let effective: [Int]
    let notEffective: [Int]
    let noEffect: [Int]
    
    public var hashValue: Int { get { return id } }
}

public func ==(lhs: GameDataType, rhs: GameDataType) -> Bool {
    return lhs.id == rhs.id
}