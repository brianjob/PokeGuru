//
//  PokeGuruTests.swift
//  PokeMathTests
//
//  Created by Brian Barton on 9/6/16.
//  Copyright © 2016 Brian Barton. All rights reserved.
//

import XCTest
@testable import PokeGuru

class PokeGuruTests: XCTestCase {
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testPokemonLoaded() {
        let pokeGuru = PokeGuru()
        
        let bulbasaur = pokeGuru.pokemon(forId: 1)
        XCTAssert(bulbasaur.id == 1)
        XCTAssert(bulbasaur.name == "Bulbasaur")
        XCTAssert(bulbasaur.types == [5, 8])
        XCTAssert(bulbasaur.baseStamina == 90)
        XCTAssert(bulbasaur.baseAttack == 126)
        XCTAssert(bulbasaur.baseDefense == 126)
        XCTAssert(bulbasaur.maxCP == 1071.54)
        XCTAssert(bulbasaur.height == 0.699999988079071)
        XCTAssert(bulbasaur.weight == 6.90000009536743)
        XCTAssert(bulbasaur.heightStdDev == 0.0874999985098838)
        XCTAssert(bulbasaur.weightStdDev == 0.862500011920928)
        XCTAssert(bulbasaur.baseCaptureRate == 0.159999996423721)
        XCTAssert(bulbasaur.baseFleeRate == 0.100000001490116)
        XCTAssert(bulbasaur.collisionRadius == 0.381500005722045)
        XCTAssert(bulbasaur.collisionHeight == 0.653999984264373)
        XCTAssert(bulbasaur.collisionHeadRadius == 0.27250000834465)
        XCTAssert(bulbasaur.movementType == "Jump")
        XCTAssert(bulbasaur.movementTimer == 10)
        XCTAssert(bulbasaur.jumpTime == 1.14999997615814)
        XCTAssert(bulbasaur.attackTimer == 29)
        XCTAssert(bulbasaur.quickMoves == [214, 221])
        XCTAssert(bulbasaur.cinematicMoves == [ 90, 59, 118 ])
        XCTAssert(bulbasaur.animationTime == [ 1.6667, 0.6667, 1.6667, 1.8333, 0, 2.1667, 1.4, 1.466667 ])
        XCTAssert(bulbasaur.evolution == 2)
        XCTAssert(bulbasaur.evolutionPips == "Normal")
        XCTAssert(bulbasaur.pokemonClass == 1)
        XCTAssert(bulbasaur.familyId == 1)
        XCTAssert(bulbasaur.candyToEvolve == 25)
        
        let mew = pokeGuru.pokemon(forId: 151)
        XCTAssert(mew.name == "Mew")
    }
    
    func testMovesLoaded() {
        let pokeGuru = PokeGuru()
        
        let wrap = pokeGuru.move(forId: 13)
        
        XCTAssert(wrap.id == 13)
        XCTAssert(wrap.name == "Wrap")
        XCTAssert(wrap.moveType == "Charge")
        XCTAssert(wrap.animationId == 5)
        XCTAssert(wrap.type == 1)
        XCTAssert(wrap.power == 25)
        XCTAssert(wrap.accuracyChance == 1)
        XCTAssert(wrap.staminaLossScalar == 0.06)
        XCTAssert(wrap.trainerLevelMin == 1)
        XCTAssert(wrap.trainerLevelMax == 100)
        XCTAssert(wrap.duration == 4000)
        XCTAssert(wrap.damageWindowStart == 2800)
        XCTAssert(wrap.damageWindowEnd == 3400)
        XCTAssert(wrap.energyDelta == -20)
        XCTAssert(wrap.criticalChance == 0.05)
        
        let rockSmash = pokeGuru.move(forId: 241)
        
        XCTAssert(rockSmash.name == "Rock Smash")
    }
    
    func testTypesLoaded() {
        let pokeGuru = PokeGuru()
        
        let normal = pokeGuru.type(forId: 1)
        
        XCTAssert(normal.id == 1)
        XCTAssert(normal.name == "Normal")
        XCTAssert(normal.effective == [])
        XCTAssert(normal.notEffective == [13, 17])
        XCTAssert(normal.noEffect == [14])
        
        let fairy = pokeGuru.type(forId: 18)
        XCTAssert(fairy.name == "Fairy")
    }
    
    // MARK: PokeMath tests
    
    func testCpModifier() {
        let pokeMath = PokeMath()

        let level4 = pokeMath.level(97, baseAtt: 126, baseDef: 126, baseStam: 90, indAtt: 0, indDef: 10, indStam: 10)
        XCTAssert(level4 == 4.0)
        
        let level31p5 = pokeMath.level(2465, baseAtt: 186, baseDef: 168, baseStam: 260, indAtt: 15, indDef: 15, indStam: 13)
        XCTAssert(level31p5 == 31.5)
        
        let level24 = pokeMath.level(1817, baseAtt: 192, baseDef: 196, baseStam: 190, indAtt: 13, indDef: 13, indStam: 15)
        XCTAssert(level24 == 24)
    }
    
    func testPerformancePokeGuru() {
        self.measureBlock {
            let _ = PokeGuru()
        }
    }
    
}
