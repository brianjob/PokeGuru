//
//  PokeMath.swift
//  PokeGuru
//
//  Created by Brian Barton on 9/6/16.
//  Copyright © 2016 Brian Barton. All rights reserved.
//

import Foundation

class PokeMath {
    private let ENERGY_PER_HP_LOST = 0.5
    private let FULL_ENERGY = 100
    private let S_CAST_TIME = 0.1

    private let E_REQ_EST = 50.0
    
    private let MIN_GEN_REQ = 15.0
    
    private let DEF_F_ATTACK_DEL = 2.0 // Defender Delay between Fast attacks after second
    
    private let C = 0.5 // damage constant
    private let DMG_MULT = 0.5 // Damage multiplier
    
    private let nC = 2.0 // Number of time generating 100 energy
    
    private let ERR = 1.0 // Extra Fast Attack - Human error doing # fast attacks more then required to get to 100 energy / rounding
    
    private let S_DMG_PWR_RED = 0.95
    
    // MARK: opponent model constants and multipliers
    
    private let DEF_Y_MULT = 2.0
    private let DEF_Y_CONST = 80.0

    private let DMG_Y_MULT = 40.0
    private let DMG_Y_CONST = -300.0
    
    private let DEF_DPS_Y_MULT = 0.02
    private let DEF_DPS_Y_CONST = 4.4

    private let ATT_DPS_Y_MULT = 0.04
    private let ATT_DPS_Y_CONST = 5.0
    
    private let OPP_LEVEL = 30.0 // player level of opponent model
    
    // cp multipliers for each level
    private let cpModifiers = [0.0940000,0.1351374,0.1663979,0.1926509,0.2157325,0.2365727,0.2557201,0.2735304,0.2902499,0.3060574,0.3210876,0.3354450,0.3492127,0.3624578,0.3752356,0.3875924,0.3995673,0.4111936,0.4225000,0.4329264,0.4431076,0.4530600,0.4627984,0.4723361,0.4816850,0.4908558,0.4998584,0.5087018,0.5173940,0.5259425,0.5343543,0.5426358,0.5507927,0.5588306,0.5667545,0.5745692,0.5822789,0.5898879,0.5974000,0.6048188,0.6121573,0.6194041,0.6265671,0.6336492,0.6406530,0.6475810,0.6544356,0.6612193,0.6679340,0.6745819,0.6811649,0.6876849,0.6941437,0.7005429,0.7068842,0.7131691,0.7193991,0.7255756,0.7317000,0.7347410,0.7377695,0.7407856,0.7437894,0.7467812,0.7497610,0.7527291,0.7556855,0.7586304,0.7615638,0.7644861,0.7673972,0.7702973,0.7731865,0.7760650,0.7789328,0.7817901,0.7846370,0.7874736,0.7903000,0.7931164]
    
    // MARK: opponent model approximations
    
    private var def_y: Double { get { return OPP_LEVEL * DEF_Y_MULT + DEF_Y_CONST }}
    private var dmg_y: Double { get { return OPP_LEVEL * DMG_Y_MULT + DMG_Y_CONST }}
    private var def_dps_y: Double { get { return OPP_LEVEL * DEF_DPS_Y_MULT + DEF_DPS_Y_CONST }}
    private var att_dps_y: Double { get {return OPP_LEVEL * ATT_DPS_Y_MULT + ATT_DPS_Y_CONST }}
    
    private var sDmgMult: Double { get { return 10 / pow(10, S_DMG_PWR_RED) } }
    
    // returns the cp modifier of the pokemon given cp, base, and individual stats
    private func calcCpModifier(cp: Double, baseAtt: Int, baseDef: Int, baseStam: Int, indAtt: Int, indDef: Int, indStam: Int) -> Double {
        let numerator = 10 * cp
        let denominator = Double(baseAtt + indAtt) * pow(Double(baseDef + indDef), 0.5) * pow(Double(baseStam + indStam), 0.5)
        return sqrt(numerator / denominator)
    }
    
    // returns cp modifier of given level
    func calcCpModifier(level: Double) -> Double {
        return cpModifiers[Int((level - 0.5) * 2.0) - 1]
    }
    
    // returns the level of the pokemon given cp, base, and individual stats
    func calcLevel(cp: Double, baseAtt: Int, baseDef: Int, baseStam: Int, indAtt: Int, indDef: Int, indStam: Int) -> Double {
        let calculatedCpM = calcCpModifier(cp, baseAtt: baseAtt, baseDef: baseDef, baseStam: baseStam, indAtt: indAtt, indDef: indDef, indStam: indStam)
        
        var closestIndexSoFar: Int = 0
        var closestDifferenceSoFar: Double = 1
        for (index, cpM) in cpModifiers.enumerate() {
            let difference = abs(calculatedCpM - cpM)
            if  difference < closestDifferenceSoFar {
                closestIndexSoFar = index
                closestDifferenceSoFar = difference
            }
        }
        
        return Double(1 + closestIndexSoFar) / 2.0 + 0.5
    }
    
    // calculate attack and defense
    func calcStat(baseStat: Double, individualStat: Double, cpModifier: Double) -> Double {
        return Double(baseStat + individualStat) * cpModifier
    }
    
    func calcHp(baseStam: Double, individualStam: Double, cpModifier: Double) -> Double {
        return floor(calcStat(baseStam, individualStat: individualStam, cpModifier: cpModifier))
    }
    
    // returns the number of charges a special move has given an energy delta
    func calcSc(energyDelta: Int) -> Int {
        return -1 * (FULL_ENERGY / energyDelta)
    }
    
    func calcEHp(hp: Double, h_xy: Double, defense: Double) -> Double {
        return ( hp - h_xy * C ) * ( defense / def_y )
    }
    
    func calcNumHits(hp: Double, defense: Double) -> Double {
        return (hp * defense) / (dmg_y + C * defense)
    }
    
    private func calcHpLostDef(hp: Double, eHp: Double, eReq: Double, fEng: Double, fDur: Double, sDur: Double,
                               sC: Double, eReqOff: Double) -> Double {
        let attackDelay = DEF_F_ATTACK_DEL * ( sC + ( ( eReqOff - 25 )) / fEng )
        
        let hpLost = att_dps_y * (hp / eHp) * (eReq / fEng * fDur + ( nC * sC - 1 ) / ( nC * sC ) * ( sDur ) * sC + attackDelay)
        
        return hpLost
    }
    
    private func eReqDefHelper(hp: Double, eHp: Double, eReq: Double, fEng: Double, fDur: Double, sDur: Double,
                               sC: Double, eReqOff: Double) -> Double {
        let hpLost = calcHpLostDef(hp, eHp: eHp, eReq: eReq, fEng: fEng, fDur: fDur, sDur: sDur, sC: sC, eReqOff: eReqOff)
        
        let eReq = 120 - hpLost * ENERGY_PER_HP_LOST
        
        return max(eReq, MIN_GEN_REQ)
    }
    
    func calcEReqDef(hp: Double, eHp: Double, fEng: Double, fDur: Double, sDur: Double,
                             sC: Double, eReqOff: Double) -> Double {
        let seed = max(MIN_GEN_REQ + 5, ( eReqOff / 3 ))
        
        var eReq = eReqDefHelper(hp, eHp: eHp, eReq: seed, fEng: fEng, fDur: fDur, sDur: sDur, sC: sC, eReqOff: eReqOff)

        for _ in 0...1 {
            eReq = eReqDefHelper(hp, eHp: eHp, eReq: eReq, fEng: fEng, fDur: fDur, sDur: sDur,sC: sC, eReqOff: eReqOff)
        }
        
        return eReq
    }
    
    private func calcHpLostOff(hp: Double, eHp: Double, eReq: Double, fEng: Double, fDur: Double, sDur: Double, sC: Double) -> Double {
        let hpLost = def_dps_y * hp/eHp * (eReq/fEng * fDur + (nC * sC - 1)/(nC * sC) * (sDur + S_CAST_TIME) * sC)
        return hpLost
    }
    
    private func eReqOffHelper(hp: Double, eHp: Double, eReq: Double, fEng: Double, fDur: Double, sDur: Double, sC: Double) -> Double {
        let hpLost = calcHpLostOff(hp, eHp: eHp, eReq: eReq, fEng: fEng, fDur: fDur, sDur: sDur, sC: sC)
        
        let eReqNext = 100 - hpLost * ENERGY_PER_HP_LOST
        
        return max(eReqNext, MIN_GEN_REQ)
    }
    
    // calculates energy required to use special attack
    func calcEReqOff(hp: Double, eHp: Double, fEng: Double, fDur: Double, sDur: Double,
                     sC: Double) -> Double {
        let eReq1 = eReqOffHelper(hp, eHp: eHp, eReq: E_REQ_EST, fEng: fEng, fDur: 1.0, sDur: sDur, sC: sC)
        let eReq2 = eReqOffHelper(hp, eHp: eHp, eReq: eReq1, fEng: fEng, fDur: fDur, sDur: sDur, sC: sC)
        
        let eReqAvg = (eReq1 + eReq2 + eReq2) / 3
        
        let eReq3 = eReqOffHelper(hp, eHp: eHp, eReq: eReqAvg, fEng: fEng, fDur: fDur, sDur: sDur, sC: sC)
        
        return eReq3
    }
    
    // approximation of dps when weaving between fast and special attacks
    func calcDpsCombo(eReq: Double, fEng: Double, fDmg: Double, sDmg: Double, fDur: Double, sDur: Double, sC: Double) -> Double {
        let numerator = ((eReq/fEng) + ERR) * fDmg + sDmg * sC
        let denominator = ((eReq/fEng) + ERR) * fDur + (sDur + S_CAST_TIME) * sC
        return numerator / denominator
    }
    
    // dps of fast attack
    func calcDpsFast(fDmg: Double, fDur: Double) -> Double {
        return fDmg / fDur
    }
    
    // dps of defender in gym
    func calcDpsDef(hp: Double, eHp: Double, fEng: Double, fDur: Double, sDur: Double, sC: Double, fDmg: Double, sDmg: Double) -> Double {
        let eReqOff = calcEReqOff(hp, eHp: eHp, fEng: fEng, fDur: fDur, sDur: sDur, sC: sC)
        let eReq = calcEReqDef(hp, eHp: eHp, fEng: fEng, fDur: fDur, sDur: sDur, sC: sC, eReqOff: eReqOff)
            
        let dps = ( ( eReq / fEng * fDmg + sDmg * sC ) / ( eReq / fEng * fDur + ( sDur ) * sC + DEF_F_ATTACK_DEL * ( eReq / fEng ) ) )
        return dps
    }
    
    // damage dealt by fast attack
    func calcFDmg(attack: Double, fPwr: Double, stab: Double) -> Double {
        return (DMG_MULT * attack * fPwr / def_y) * stab + C
    }
    
    // damage dealt by special attack
    func calcSDmg(attack: Double, sPwr: Double, stab: Double) -> Double {
        return pow((DMG_MULT * attack * sPwr / def_y) * stab + C, S_DMG_PWR_RED) * sDmgMult
    }
    
    // total damage output when attacking gym
    func calcOffTdo(dps: Double, eHp: Double) -> Double {
        return dps * eHp / def_dps_y
    }
    
    // total damage output when defending gym
    func calcDefTdo(dpsDef: Double, eHpDef: Double) -> Double {
        return dpsDef * eHpDef / att_dps_y
    }
 }