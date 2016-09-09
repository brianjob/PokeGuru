//
//  GameDataTests.swift
//  PokeGuru
//
//  Created by Brian Barton on 9/9/16.
//  Copyright © 2016 Brian Barton. All rights reserved.
//

import XCTest
@testable import PokeGuru

class GameDataTests: XCTestCase {
    
    private func getTestPokemon(id: Int, types: [GameDataType] = []) -> GameDataPokemon {
        return GameDataPokemon(id: id,
                               name: "",
                               types: types,
                               baseStamina: 0,
                               baseAttack: 0,
                               baseDefense: 0,
                               maxCP: 0.0,
                               height: 0.0,
                               weight: 0.0,
                               heightStdDev: 0.0,
                               weightStdDev: 0.0,
                               baseCaptureRate: 0.0,
                               baseFleeRate: 0.0,
                               collisionRadius: 0.0,
                               collisionHeight: 0.0,
                               collisionHeadRadius: 0.0,
                               movementType: "",
                               movementTimer: 0,
                               jumpTime: 0.0,
                               attackTimer: 0,
                               quickMoves: [],
                               cinematicMoves: [],
                               animationTime: [],
                               evolution: nil,
                               evolutionPips: "",
                               pokemonClass: 0,
                               familyId: 0,
                               candyToEvolve: 0)
        
    }
    
    private func getTestType(id: Int, effective: [Int], notEffective: [Int], noEffect: [Int]) -> GameDataType {
        return GameDataType(id: id,
                            name: "",
                            effective: effective,
                            notEffective: notEffective,
                            noEffect: noEffect)
    }
    
    private func getTestMove(id: Int, type: GameDataType) -> GameDataMove {
        return GameDataMove(id: id,
                            name: "",
                            moveType: "",
                            animationId: 0,
                            type: type,
                            power: 0,
                            accuracyChance: 0.0,
                            staminaLossScalar: 0.0,
                            trainerLevelMin: 0.0,
                            trainerLevelMax: 0.0,
                            duration: 0,
                            damageWindowStart: 0,
                            damageWindowEnd: 0,
                            energyDelta: 0,
                            criticalChance: 0.0)
    }
    
    func testGameDataPokemonCompare() {
        let a = getTestPokemon(1)
        let b = getTestPokemon(1)
        let c = getTestPokemon(2)
        
        XCTAssert(a == b)
        XCTAssert(b != c)
    }
    
    func testGameDataTypeCompare() {
        let a = getTestType(1, effective: [], notEffective: [], noEffect: [])
        
        let b = getTestType(1, effective: [], notEffective: [], noEffect: [])
        
        let c = getTestType(2, effective: [], notEffective: [], noEffect: [])
        
        XCTAssert(a == b)
        XCTAssert(b != c)
    }
    
    func testGameDataMoveCompare() {
        let type = getTestType(1, effective: [], notEffective: [], noEffect: [])
        let a = getTestMove(1, type: type)
        let b = getTestMove(1, type: type)
        let c = getTestMove(2, type: type)
        
        XCTAssert(a == b)
        XCTAssert(b != c)
    }
    
    func testMoveDataEffective() {
        let typeA = getTestType(1, effective: [], notEffective: [], noEffect: [])
        
        let typeB = getTestType(2, effective: [1], notEffective: [], noEffect: [])
        
        let pokemon = getTestPokemon(1, types: [typeA])
        let move = getTestMove(2, type: typeB)
        
        let mult = move.calcTypeModifier(pokemon)
        
        XCTAssert(mult == 1.25)
    }
    
    func testMoveDataNotEffective() {
        let typeA = getTestType(1, effective: [], notEffective: [], noEffect: [])
        
        let typeB = getTestType(2, effective: [], notEffective: [1], noEffect: [])
        
        let pokemon = getTestPokemon(1, types: [typeA])
        let move = getTestMove(2, type: typeB)
        
        let mult = move.calcTypeModifier(pokemon)
        
        XCTAssert(mult == 0.8)
    }
    
    func testMoveDataNoEffect() {
        let typeA = getTestType(1, effective: [], notEffective: [], noEffect: [])
        
        let typeB = getTestType(2, effective: [], notEffective: [], noEffect: [1])
        
        let pokemon = getTestPokemon(1, types: [typeA])
        let move = getTestMove(2, type: typeB)
        
        let mult = move.calcTypeModifier(pokemon)
        
        XCTAssert(mult == 0.8)
    }
    
    func testMoveDataDoubleEffective() {
        let typeA = getTestType(1, effective: [], notEffective: [], noEffect: [])
        
        let typeB = getTestType(2, effective: [], notEffective: [], noEffect: [])
        
        let typeC = getTestType(3, effective: [1, 2], notEffective: [], noEffect: [])
        
        let pokemon = getTestPokemon(1, types: [typeA, typeB])
        let move = getTestMove(2, type: typeC)
        
        let mult = move.calcTypeModifier(pokemon)
        
        XCTAssert(mult == 1.25 * 1.25)
    }
    
    func testMoveDataDoubleNotEffective() {
        let typeA = getTestType(1, effective: [], notEffective: [], noEffect: [])
        
        let typeB = getTestType(2, effective: [], notEffective: [], noEffect: [])
        
        let typeC = getTestType(3, effective: [], notEffective: [1, 2], noEffect: [])
        
        let pokemon = getTestPokemon(1, types: [typeA, typeB])
        let move = getTestMove(2, type: typeC)
        
        let mult = move.calcTypeModifier(pokemon)
        
        XCTAssert(mult == 0.8 * 0.8)
    }
    
    func testMoveDataCancellingEffects() {
        let typeA = getTestType(1, effective: [], notEffective: [], noEffect: [])
        
        let typeB = getTestType(2, effective: [], notEffective: [], noEffect: [])
        
        let typeC = getTestType(3, effective: [1], notEffective: [2], noEffect: [])
        
        let pokemon = getTestPokemon(1, types: [typeA, typeB])
        let move = getTestMove(2, type: typeC)
        
        let mult = move.calcTypeModifier(pokemon)
        
        XCTAssert(mult == 1)
    }
    
    func testGameDataTypeIdIsHashValue() {
        let type = getTestType(1, effective: [], notEffective: [], noEffect: [])
        
        XCTAssert(type.id == type.hashValue)
    }
}
