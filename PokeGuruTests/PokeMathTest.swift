//
//  PokeMathTest.swift
//  PokeGuru
//
//  Created by Brian Barton on 9/8/16.
//  Copyright © 2016 Brian Barton. All rights reserved.
//

import XCTest
@testable import PokeGuru

class PokeMathTest: XCTestCase {
    // MARK: test values for charmander
    private let baseAtt = 128.0
    private let baseDef = 108.0
    private let baseStam = 78.0
    private let indAtt = 7.5
    private let indDef = 7.5
    private let indStam = 7.5
    private let cpM = 0.7317
    private let hp = 62.00000
    private let atk = 99.14535
    private let def = 84.51135
    private let fDmg = 4.92613
    private let sDmg = 11.48154
    private let h_xy = 5.56081
    private let eHp = 35.74806
    private let eReq = 25.94653
    private let dpsCombo = 3.79862
    private let tdo = 33.54279
    private let eReqDef = 15.00000
    private let eHpDef = 68.13932
    private let dpsDef = 3.22774
    private let tdoDef = 35.47355
    private let fPwr = 10.0
    private let fDur = 1.05
    private let fEng = 10.0
    private let sPwr = 25.0
    private let sDur = 3.10
    private let sC = 5.0
    private let stab = 1.25
    private let fDps = 4.69155
    
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    let delta = 0.0001
    func equal(a: Double, _ b: Double) -> Bool {
        return abs(a - b) < delta
    }
    
    func testCalcLevel() {
        let pokeMath = PokeMath()
        
        let level4 = pokeMath.calcLevel(97, baseAtt: 126, baseDef: 126, baseStam: 90, indAtt: 0, indDef: 10, indStam: 10)
        XCTAssert(level4 == 4.0)
        
        let level31p5 = pokeMath.calcLevel(2465, baseAtt: 186, baseDef: 168, baseStam: 260, indAtt: 15, indDef: 15, indStam: 13)
        XCTAssert(level31p5 == 31.5)
        
        let level24 = pokeMath.calcLevel(1817, baseAtt: 192, baseDef: 196, baseStam: 190, indAtt: 13, indDef: 13, indStam: 15)
        XCTAssert(level24 == 24)
    }
    
    func testCalcCpModifier() {
        let pokeMath = PokeMath()

        let maxLevel = 40.5
        let maxLevelCpM = 0.7931164
        let maxLevelCpMTest = pokeMath.calcCpModifier(maxLevel)
        XCTAssert(maxLevelCpMTest == maxLevelCpM)
        
        let minLevel = 1.0
        let minLevelCpM = 0.0940000
        let minLevelCpMTest = pokeMath.calcCpModifier(minLevel)
        XCTAssert(minLevelCpMTest == minLevelCpM)
    }
    
    func testCalcStat() {
        let pokeMath = PokeMath()
        
        let attTest = pokeMath.calcStat(baseAtt, individualStat: indAtt, cpModifier: cpM)
        let defTest = pokeMath.calcStat(baseDef, individualStat: indDef, cpModifier: cpM)
        let hpTest = pokeMath.calcHp(baseStam, individualStam: indStam, cpModifier: cpM)
        
        XCTAssert(equal(attTest,atk))
        XCTAssert(equal(defTest,def))
        XCTAssert(equal(hpTest,hp))
    }
    
    func testCalcNumHits() {
        let pokeMath = PokeMath()
        
        let h_xyTest = pokeMath.calcNumHits(hp, defense: def)
        
        XCTAssert(equal(h_xyTest, h_xy))
    }
    
    func testCalcEHp() {
        let pokeMath = PokeMath()
        
        let eHpTest = pokeMath.calcEHp(hp, h_xy: h_xy, defense: def)
        
        XCTAssert(equal(eHpTest, eHp))
    }
    
    func testCalcEReqOff() {
        let pokeMath = PokeMath()
        
        let eReqTest = pokeMath.calcEReqOff(hp, eHp: eHp, fEng: fEng, fDur: fDur, sDur: sDur, sC: sC)
        
        XCTAssert(equal(eReqTest, eReq))
    }
    
    func testCalcEReqDef() {
        let pokeMath = PokeMath()
        
        let eReqTest = pokeMath.calcEReqDef(hp, eHp: eHp, fEng: fEng, fDur: fDur, sDur: sDur, sC: sC, eReqOff: eReq)
        
        XCTAssert(equal(eReqTest, eReqDef))
    }
    
    func testCalcDpsCombo() {
        let pokeMath = PokeMath()
        
        let dpsComboTest = pokeMath.calcDpsCombo(eReq, fEng: fEng, fDmg: fDmg, sDmg: sDmg, fDur: fDur, sDur: sDur, sC: sC)
        
        XCTAssert(equal(dpsComboTest, dpsCombo))
    }
    
    func testCalcDpsFast() {
        let pokeMath = PokeMath()
        
        let dpsFastTest = pokeMath.calcDpsFast(fDmg, fDur: fDur)
        
        XCTAssert(equal(dpsFastTest, fDps))
    }
    
    func testCalcDpsDef() {
        let pokeMath = PokeMath()
        
        let dpsDefTest = pokeMath.calcDpsDef(hp, eHp: eHp, fEng: fEng, fDur: fDur, sDur: sDur, sC: sC, fDmg: fDmg, sDmg: sDmg)
        
        XCTAssert(equal(dpsDefTest, dpsDef))
    }
    
    func testCalcFDmg() {
        let pokeMath = PokeMath()
        
        let fDmgTest = pokeMath.calcFDmg(atk, fPwr: fPwr, stab: stab)
        
        XCTAssert(equal(fDmgTest, fDmg))
    }
    
    func testCalcSDmg() {
        let pokeMath = PokeMath()
        
        let sDmgTest = pokeMath.calcSDmg(atk, sPwr: sPwr, stab: stab)
        
        XCTAssert(equal(sDmgTest, sDmg))
    }
    
    func testCalcOffTdo() {
        let pokeMath = PokeMath()
        
        let offTdoTest = pokeMath.calcOffTdo(fDps, eHp: eHp)
        
        XCTAssert(equal(offTdoTest, tdo))
    }
    
    func testDefTdo() {
        let pokeMath = PokeMath()
        
        let defTdoTest = pokeMath.calcDefTdo(dpsDef, eHpDef: eHpDef)
        
        XCTAssert(equal(defTdoTest, tdoDef))
    }
    
    func testNumSpecialCharges() {
        let pokeMath = PokeMath()
        
        let testSc = pokeMath.calcSc(-33)
        
        XCTAssert(testSc == 3)
    }
}
