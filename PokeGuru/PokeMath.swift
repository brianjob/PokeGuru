//
//  PokeMath.swift
//  PokeGuru
//
//  Created by Brian Barton on 9/6/16.
//  Copyright © 2016 Brian Barton. All rights reserved.
//

import Foundation

class PokeMath {
    private let STAB_MODIFIER = 1.25
    private let ENERGY_PER_HP_LOST = 0.5
    private let FULL_ENERGY = 100
    private let S_CAST_TIME = 0.1
    private let EFFECTIVE_MODIFIER = 1.25
    private let NOT_EFFECTIVE_MODIFIER = 0.8
    private let NO_EFFECT_MODIFIER = 0.8

    private let E_REQ_EST = 50.0
    
    private let MIN_GEN_REQ = 15.0
    
    private let DEF_F_ATTACK_DEL = 2.0 // Defender Delay between Fast attacks after second
    
    // MARK: opponent model constants and multipliers
    
    private let DEF_Y_MULT = 2.0
    private let DEF_Y_CONST = 80.0

    private let DMG_Y_MULT = 40.0
    private let DMG_Y_CONST = -300.0
    
    private let DEF_DPS_Y_MULT = 0.02
    private let DEF_DPS_Y_CONST = 4.4

    private let ATT_DPS_Y_MULT = 0.04
    private let ATT_DPS_Y_CONST = 5.0
    
    private let C = 0.5 // damage constant
    private let DMG_MULT = 0.5 // Damage multiplier
    
    private let nC = 2.0 // Number of time generating 100 energy
    
    private let ERR = 1.0 // Extra Fast Attack - Human error doing # fast attacks more then required to get to 100 energy / rounding
    
    private let S_DMG_PWR_RED = 0.95
    
    private let oppLevel = 30.0 // player level of opponent model
    
    // cp multipliers for each level
    private let cpModifiers = [0.0940000,0.1351374,0.1663979,0.1926509,0.2157325,0.2365727,0.2557201,0.2735304,0.2902499,0.3060574,0.3210876,0.3354450,0.3492127,0.3624578,0.3752356,0.3875924,0.3995673,0.4111936,0.4225000,0.4329264,0.4431076,0.4530600,0.4627984,0.4723361,0.4816850,0.4908558,0.4998584,0.5087018,0.5173940,0.5259425,0.5343543,0.5426358,0.5507927,0.5588306,0.5667545,0.5745692,0.5822789,0.5898879,0.5974000,0.6048188,0.6121573,0.6194041,0.6265671,0.6336492,0.6406530,0.6475810,0.6544356,0.6612193,0.6679340,0.6745819,0.6811649,0.6876849,0.6941437,0.7005429,0.7068842,0.7131691,0.7193991,0.7255756,0.7317000,0.7347410,0.7377695,0.7407856,0.7437894,0.7467812,0.7497610,0.7527291,0.7556855,0.7586304,0.7615638,0.7644861,0.7673972,0.7702973,0.7731865,0.7760650,0.7789328,0.7817901,0.7846370,0.7874736,0.7903000,0.7931164]
    
    // MARK: opponent model approximations
    
    private var def_y: Double { get { return oppLevel * DEF_Y_MULT + DEF_Y_CONST }}
    private var dmg_y: Double { get { return oppLevel * DMG_Y_MULT + DMG_Y_CONST }}
    private var def_dps_y: Double { get { return oppLevel * DEF_DPS_Y_MULT + DEF_DPS_Y_CONST }}
    private var att_dps_y: Double { get {return oppLevel * ATT_DPS_Y_MULT + ATT_DPS_Y_CONST }}
    
    private var sDmgMult: Double { get { return 10 / pow(10, S_DMG_PWR_RED) } }
    
    // returns the cp modifier of the pokemon given cp, base, and individual stats
    private func calcCpModifier(cp: Double, baseAtt: Int, baseDef: Int, baseStam: Int, indAtt: Int, indDef: Int, indStam: Int) -> Double {
        let numerator = 10 * cp
        let denominator = Double(baseAtt + indAtt) * pow(Double(baseDef + indDef), 0.5) * pow(Double(baseStam + indStam), 0.5)
        return sqrt(numerator / denominator)
    }
    
    // returns cp modifier of given level
    private func calcCpModifier(level: Double) -> Double {
        return cpModifiers[Int((level - 0.5) * 2.0) - 1]
    }
    
    // returns the level of the pokemon given cp, base, and individual stats
    private func calcLevel(cp: Double, baseAtt: Int, baseDef: Int, baseStam: Int, indAtt: Int, indDef: Int, indStam: Int) -> Double {
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
    
    private func calcAttack(baseAttack: Int, individualAttack: Int, cpModifier: Double) -> Double {
        return Double(baseAttack + individualAttack) * cpModifier
    }
    
    private func calcDefense(baseDefense: Int, individualDefense: Int, cpModifier: Double) -> Double {
        return Double(baseDefense + individualDefense) * cpModifier
    }
    
    private func calcHp(baseStamina: Int, individualStamina: Int, cpModifier: Double) -> Double {
        return Double(baseStamina + individualStamina) * cpModifier
    }
    
    // returns the type modifier of a move against a given defender
    private func calcTypeModifier(move: GameDataMove, defender: GameDataPokemon) -> Double {
        var typeModifier = 1.0
        
        for type in defender.types {
            if move.type.effective.contains(type.id) {
                typeModifier *= EFFECTIVE_MODIFIER
            }
            if move.type.notEffective.contains(type.id) {
                typeModifier *= NOT_EFFECTIVE_MODIFIER
            }
            if move.type.noEffect.contains(type.id) {
                typeModifier *= NO_EFFECT_MODIFIER
            }
        }

        return typeModifier
    }
    
    // returns he number of charges a special move has given an energy delta
    private func numSpecialCharges(energyDelta: Int) -> Int {
        return -1 * (energyDelta / FULL_ENERGY)
    }
    
    // converts a duration in ms to seconds
    private func durationInSeconds(durationInMs: Int) -> Double {
        return Double(durationInMs) / 1000.0
    }
    
    private func calcEffectiveHp(hp: Int, h_xy: Double, pokemon: GameDataPokemon, individualDefense: Int, pokemonLevel: Double) -> Double {
        let cpMod = calcCpModifier(pokemonLevel)
        let def_x = calcDefense(pokemon.baseDefense, individualDefense: individualDefense, cpModifier: cpMod)
        
        return ( Double(hp) - h_xy * C ) * ( def_x / def_y )
    }
    
    private func calcNumHits(hp: Double, def_x: Double) -> Double {
        return (hp * def_x) / (dmg_y + C * def_x)
    }
    
    private func calcHpLostDef(hp: Double, eHp: Double, eReq: Double, fEng: Double, fDur: Double, sDur: Double,
                               nC: Double, sC: Double, eReqOff: Double) -> Double {
        let attackDelay = DEF_F_ATTACK_DEL * ( sC + ( ( eReqOff - 25 )) / fEng )
        
        let hpLost = att_dps_y * (hp / eHp) * (eReq / fEng * fDur + ( nC * sC - 1 ) / ( nC * sC ) * ( sDur ) * sC + attackDelay)
        
        return hpLost
    }
    
    private func eReqDefHelper(hp: Double, eHp: Double, eReq: Double, fEng: Double, fDur: Double, sDur: Double,
                               nC: Double, sC: Double, eReqOff: Double) -> Double {
        let hpLost = calcHpLostDef(hp, eHp: eHp, eReq: eReq, fEng: fEng, fDur: fDur, sDur: sDur, nC: nC, sC: sC, eReqOff: eReqOff)
        
        let eReq = 120 - hpLost * ENERGY_PER_HP_LOST
        
        return max(eReq, MIN_GEN_REQ)
    }
    
    private func calcEReqDef(hp: Double, eHp: Double, fEng: Double, fDur: Double, sDur: Double,
                             nC: Double, sC: Double, eReqOff: Double) -> Double {
        let seed = max(MIN_GEN_REQ + 5, ( eReqOff / 3 ))
        
        var eReq = eReqDefHelper(hp, eHp: eHp, eReq: seed, fEng: fEng, fDur: fDur, sDur: sDur, nC: nC, sC: sC, eReqOff: eReqOff)

        for _ in 0...1 {
            eReq = eReqDefHelper(hp, eHp: eHp, eReq: eReq, fEng: fEng, fDur: fDur, sDur: sDur, nC: nC, sC: sC, eReqOff: eReqOff)
        }
        
        return eReq
    }
    
    private func calcHpLostOff(hp: Double, eHp: Double, eReq: Double, fEng: Double, fDur: Double, sDur: Double,
                               nC: Double, sC: Double) -> Double {
        let hpLost = def_dps_y * (hp/eHp) * (eReq/fEng) * fDur + ((nC * sC - 1) / (nC * sC)) * (sDur + S_CAST_TIME) * sC
        return hpLost
    }
    
    private func eReqOffHelper(hp: Double, eHp: Double, eReq: Double, fEng: Double, fDur: Double, sDur: Double,
                            nC: Double, sC: Double) -> Double {
        let hpLost = calcHpLostOff(hp, eHp: eHp, eReq: eReq, fEng: fEng, fDur: fDur, sDur: sDur, nC: nC, sC: sC)
        
        let eReq = 100 - hpLost * ENERGY_PER_HP_LOST
        
        return max(eReq, MIN_GEN_REQ)
    }
    
    // calculates energy required to use special attack
    private func calcEReqOff(hp: Double, eHp: Double, fEng: Double, fDur: Double, sDur: Double,
                          nC: Double, sC: Double) -> Double {
        let eReq1 = eReqOffHelper(hp, eHp: eHp, eReq: E_REQ_EST, fEng: fEng, fDur: 1.0, sDur: sDur, nC: nC, sC: sC)
        let eReq2 = eReqOffHelper(hp, eHp: eHp, eReq: eReq1, fEng: fEng, fDur: fDur, sDur: sDur, nC: nC, sC: sC)
        
        let eReqAvg = (eReq1 + eReq2 + eReq2) / 3
        
        let eReq3 = eReqOffHelper(hp, eHp: eHp, eReq: eReqAvg, fEng: fEng, fDur: fDur, sDur: sDur, nC: nC, sC: sC)
        
        return eReq3
    }
    
    // approximation of dps when weaving between fast and special attacks
    private func dpsCombo(eReq: Double, fEng: Double, fDmg: Double, sDmg: Double, fDur: Double, sDur: Double, sC: Double) -> Double {
        let numerator = ((eReq/fEng) + ERR) * fDmg + sDmg * sC
        let denominator = ((eReq/fEng) + ERR) * fDur + (sDur + S_CAST_TIME) * sC
        return numerator / denominator
    }
    
    private func dpsDef(hp: Double, eHp: Double, fEng: Double, fDur: Double, sDur: Double,
                        nC: Double, sC: Double, fDmg: Double, sDmg: Double) -> Double {
        let eReqOff = calcEReqOff(hp, eHp: eHp, fEng: fEng, fDur: fDur, sDur: sDur, nC: nC, sC: sC)
        let eReq = calcEReqDef(hp, eHp: eHp, fEng: fEng, fDur: fDur, sDur: sDur, nC: nC, sC: sC, eReqOff: eReqOff)
            
        let dps = ( ( eReq / fEng * fDmg + sDmg * sC ) / ( eReq / fEng * fDur + ( sDur ) * sC + DEF_F_ATTACK_DEL * ( eReq / fEng ) ) )
        return dps
    }
    
    private func calcFDmg(attack: Double, fPwr: Double, stab: Double) -> Double {
        return (DMG_MULT * attack * fPwr / def_y) * stab + C
    }
    
    private func calcSDmg(attack: Double, sPwr: Double, stab: Double) -> Double {
        return pow((DMG_MULT * attack * sPwr / def_y) * stab + C, S_DMG_PWR_RED) * sDmgMult
    }
    
//    // gets the damage done per second of a quick attack
//    func dpsFast(attack: Double, defense: Double, movePower: Int, stab: Bool, critChance: Double,
//                 accuracy: Double, typeModifier: Double, duration: Int) -> Double {
//        return moveDamage(attack, defense: defense, movePower: movePower, stab: stab,
//                          critChance: critChance, accuracy: accuracy, typeModifier: typeModifier) /
//                durationInSeconds(duration)
//    }
//    
//    // gets the damage done per second of a special attack (doesn't take charging into account)
//    func dpsSpecial(attack: Double, defense: Double, movePower: Int, stab: Bool, critChance: Double,
//                    accuracy: Double, typeModifier: Double, duration: Int) -> Double {
//        return moveDamage(attack, defense: defense, movePower: movePower, stab: stab,
//                          critChance: critChance, accuracy: accuracy, typeModifier: typeModifier) /
//                durationInSeconds(duration) + SPECIAL_CAST_TIME
//    }
//    
//    func setUpDpsCalc(attacker: GameDataPokemon, attackerIndividualAtt: Int, attackerCpMod: Double,
//        defender: GameDataPokemon, defenderIndividualDef: Int, defenderCpMod: Double,
//        fastMove: GameDataMove, specialMove: GameDataMove) -> (fDmg: Double, sDmg: Double, sC: Double, eReq: Double, fEng: Double, fDur: Double, sDur: Double) {
//
//        let attack = calcAttack(attacker.baseAttack, individualAttack: attackerIndividualAtt, cpModifier: attackerCpMod)
//        let defense = calcDefense(defender.baseDefense, individualDefense: defenderIndividualDef, cpModifier: defenderCpMod)
//        
//        let typeModifierFast = calcTypeModifier(fastMove, defender: defender)
//        let typeModifierSpecial = calcTypeModifier(specialMove, defender: defender)
//        
//        let fastStab = attacker.types.contains(fastMove.type)
//        let specialStab = attacker.types.contains(specialMove.type)
//        
//        let fDmg = moveDamage(attack, defense: defense, movePower: fastMove.power, stab: fastStab,
//                              critChance: fastMove.criticalChance, accuracy: fastMove.accuracyChance, typeModifier: typeModifierFast)
//        
//        let sDmg = moveDamage(attack, defense: defense, movePower: specialMove.power, stab: specialStab,
//                              critChance: specialMove.criticalChance, accuracy: specialMove.accuracyChance, typeModifier: typeModifierSpecial)
//        
//        let sC = Double(numSpecialCharges(specialMove.energyDelta))
//        let eReq = energyGenerationRequired(0) // setting hp lost to 0 for now
//        let fEng = Double(fastMove.energyDelta)
//        let fDur = Double(fastMove.duration)
//        let sDur = Double(specialMove.duration)
//        
//        return (fDmg, sDmg, sC, eReq, fEng, fDur, sDur)
//
//    }
//    
//    // damage per second attacker will do to defender while attacker is attacking gym
//    func dpsOffense(attacker: GameDataPokemon, attackerIndividualAtt: Int, attackerCpMod: Double,
//                    defender: GameDataPokemon, defenderIndividualDef: Int, defenderCpMod: Double,
//                    fastMove: GameDataMove, specialMove: GameDataMove) -> Double {
//        let t = setUpDpsCalc(attacker, attackerIndividualAtt: attackerIndividualAtt, attackerCpMod: attackerCpMod,
//                             defender: defender, defenderIndividualDef: defenderIndividualDef, defenderCpMod:  defenderCpMod,
//                             fastMove: fastMove, specialMove: specialMove)
//
//        let err = 1.0 // setting err to 1 for now since I don't know how to estimate
//        
//        let numerator = (t.eReq/t.fEng + err) * t.fDmg + t.sDmg * t.sC
//        let denominator = (t.eReq/t.fEng + err) * t.fDur + (t.sDur + SPECIAL_CAST_TIME) * t.sC
//        let dps = numerator / denominator
//        
//        return dps
//    }
//    
//    // damage per second attacker will do to defender while attacker is defending gym
//    func dpsDefense(attacker: GameDataPokemon, attackerIndividualAtt: Int, attackerCpMod: Double,
//                    defender: GameDataPokemon, defenderIndividualDef: Int, defenderCpMod: Double,
//                    fastMove: GameDataMove, specialMove: GameDataMove) -> Double {
//        let t = setUpDpsCalc(attacker, attackerIndividualAtt: attackerIndividualAtt, attackerCpMod: attackerCpMod,
//                             defender: defender, defenderIndividualDef: defenderIndividualDef, defenderCpMod: defenderCpMod,
//                             fastMove: fastMove, specialMove: specialMove)
//        
//        let numerator = (t.eReq/t.fEng) * t.fDmg + t.sDmg * t.sC
//        let denominator = (t.eReq/t.fEng) * t.fDur + t.sDur * t.sC + 2 * (t.sC + t.eReq/t.fEng)
//        let dps = numerator / denominator
//        
//        return dps
//    }
    
//    func calcEffectiveHp(attacker: GameDataPokemon, attackerIndividualDefense: Int, attackerIndividualStamina: Int,
//                     attackerCpMod: Double, defenderLevel: Double) -> Double {
//        let hp = calcHp(attacker.baseStamina, individualStamina: attackerIndividualStamina, cpModifier: attackerCpMod)
//        let defense = calcDefense(attacker.baseDefense, individualDefense: attackerIndividualDefense, cpModifier: attackerCpMod)
//
//        return hp - DAMAGE_CONSTANT * (
//            (hp * defense) /
//            (oppDamage(defenderLevel) + DAMAGE_CONSTANT * defense)
//        ) * (defense/oppDef(defenderLevel))
//    }
    
//    func offensiveTdo(attacker: GameDataPokemon, attackerIndividualAtt: Int, attackerIndividualDef: Int,
//                      attackerIndividualStam: Int, attackerCpMod: Double,
//                      defender: GameDataPokemon, defenderIndividualDef: Int, defenderCpMod: Double,
//                      fastMove: GameDataMove, specialMove: GameDataMove, defenderLevel: Double) -> Double {
//        let dps = dpsOffense(attacker, attackerIndividualAtt: attackerIndividualAtt, attackerCpMod: attackerCpMod,
//                             defender: defender, defenderIndividualDef: defenderIndividualDef, defenderCpMod: defenderCpMod,
//                             fastMove: fastMove, specialMove: specialMove)
//        
//        let effectiveHp = calcEffectiveHp(attacker, attackerIndividualDefense: attackerIndividualDef,
//                                      attackerIndividualStamina: attackerIndividualStam,
//                                      attackerCpMod: attackerCpMod, defenderLevel: defenderLevel)
//        
//        let tdo = dps * (effectiveHp / oppDps(defenderLevel))
//        return tdo
//    }
    
//    func defensiveTdo() -> Double {
//        
//    }
    // the number of hits an attacker will take while attacker is attacking gym
//    func numHitsOffense(attacker: GameDataPokemon, attackerIndividualDefense: Int, attackerIndividualStamina: Int, attackerCpMod: Double,
//                 defender: GameDataPokemon, defenderIndividualAttack: Int, defenderCpMod: Double, defenderFastMove: GameDataMove,
//                 defenderStab: Bool) -> Int {
//        let attackerHp = calcHp(attacker.baseStamina, individualStamina: attackerIndividualStamina, cpModifier: attackerCpMod)
//        
//        oppDamage(defenderLevel)
//        let attackerDefense = calcDefense(attacker.baseDefense, individualDefense: attackerIndividualDefense, cpModifier: attackerCpMod)
//        let defenderAttack = calcAttack(defender.baseAttack, individualAttack: defenderIndividualAttack, cpModifier: defenderCpMod)
//
//        let typeModifier = calcTypeModifier(defenderFastMove, defender: attacker)
//        let fDmg = moveDamage(defenderAttack, defense: attackerDefense, movePower: defenderFastMove.power, stab: defenderStab,
//                              critChance: defenderFastMove.criticalChance, accuracy: defenderFastMove.accuracyChance, typeModifier: typeModifier)
//        
//        let numHits = attackerHp / fDmg
//        
//        return Int(ceil(numHits))
//    }
    
    // the number of hits an attacker will take while attacker is defending gym
//    func numHitsDefense(attacker: GameDataPokemon, attackerIndividualDefense: Int, attackerIndividualStamina: Int, attackerCpMod: Double,
//                        defender: GameDataPokemon, defenderIndividualAttack: Int, defenderCpMod: Double, defenderFastMove: GameDataMove,
//                        defenderStab: Bool) -> Int {
//        return 2 * numHitsOffense(attacker, attackerIndividualDefense: attackerIndividualDefense, attackerIndividualStamina: attackerIndividualStamina,
//                                  attackerCpMod: attackerCpMod, defender: defender, defenderIndividualAttack: defenderIndividualAttack,
//                                  defenderCpMod: defenderCpMod, defenderFastMove: defenderFastMove, defenderStab: defenderStab)
//    }

//    func effectiveHp(attacker: GameDataPokemon, attackerIndividualDefense: Int, attackerIndividualStamina: Int, attackerCpMod: Double,
//                     defender: GameDataPokemon, defenderIndividualAttack: Int, defenderCpMod: Double, defenderFastMove: GameDataMove,
//                     defenderStab: Bool) -> Double {
//        let hp = calcHp(attacker.baseStamina, individualStamina: attackerIndividualStamina, cpModifier: attackerCpMod)
//        let numHits = numHitsOffense(attacker, attackerIndividualDefense: attackerIndividualDefense, attackerIndividualStamina: attackerIndividualStamina,
//                                     attackerCpMod: attackerCpMod, defender: defender, defenderIndividualAttack: defenderIndividualAttack,
//                                     defenderCpMod: defenderCpMod, defenderFastMove: defenderFastMove, defenderStab: defenderStab)
//        
//        let typeModifier = calcTypeModifier(defenderFastMove, defender: attacker)
//        
//        let constD = Double(numHits) * Double(DAMAGE_CONSTANT) * (defenderStab ? STAB_MODIFIER : 1.0) * typeModifier
//        
//        let effHp = (hp - constD) *
//    }
}