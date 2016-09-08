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
        let bulbasaur = PokeGuru.pokemon(forId: 1)
        XCTAssert(bulbasaur.id == 1)
        XCTAssert(bulbasaur.name == "Bulbasaur")
        XCTAssert(bulbasaur.types == [PokeGuru.type(forId: 5), PokeGuru.type(forId: 8)])
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
        
        let mew = PokeGuru.pokemon(forId: 151)
        XCTAssert(mew.name == "Mew")
    }
    
    func testMovesLoaded() {
        let wrap = PokeGuru.move(forId: 13)
        
        XCTAssert(wrap.id == 13)
        XCTAssert(wrap.name == "Wrap")
        XCTAssert(wrap.moveType == "Charge")
        XCTAssert(wrap.animationId == 5)
        XCTAssert(wrap.type == PokeGuru.type(forId: 1))
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
        
        let rockSmash = PokeGuru.move(forId: 241)
        
        XCTAssert(rockSmash.name == "Rock Smash")
    }
    
    func testTypesLoaded() {
        let normal = PokeGuru.type(forId: 1)
        
        XCTAssert(normal.id == 1)
        XCTAssert(normal.name == "Normal")
        XCTAssert(normal.effective == [])
        XCTAssert(normal.notEffective == [13, 17])
        XCTAssert(normal.noEffect == [14])
        
        let fairy = PokeGuru.type(forId: 18)
        XCTAssert(fairy.name == "Fairy")
    }
    
    func testPerformancePokeGuru() {
        self.measureBlock {
            let _ = PokeGuru()
        }
    }
    
}
