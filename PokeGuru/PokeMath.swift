//
//  PokeMath.swift
//  PokeGuru
//
//  Created by Brian Barton on 9/6/16.
//  Copyright © 2016 Brian Barton. All rights reserved.
//

import Foundation

class PokeMath {
    // cp multipliers for each level
    private let cpModifiers = [0.0940000,0.1351374,0.1663979,0.1926509,0.2157325,0.2365727,0.2557201,0.2735304,0.2902499,0.3060574,0.3210876,0.3354450,0.3492127,0.3624578,0.3752356,0.3875924,0.3995673,0.4111936,0.4225000,0.4329264,0.4431076,0.4530600,0.4627984,0.4723361,0.4816850,0.4908558,0.4998584,0.5087018,0.5173940,0.5259425,0.5343543,0.5426358,0.5507927,0.5588306,0.5667545,0.5745692,0.5822789,0.5898879,0.5974000,0.6048188,0.6121573,0.6194041,0.6265671,0.6336492,0.6406530,0.6475810,0.6544356,0.6612193,0.6679340,0.6745819,0.6811649,0.6876849,0.6941437,0.7005429,0.7068842,0.7131691,0.7193991,0.7255756,0.7317000,0.7347410,0.7377695,0.7407856,0.7437894,0.7467812,0.7497610,0.7527291,0.7556855,0.7586304,0.7615638,0.7644861,0.7673972,0.7702973,0.7731865,0.7760650,0.7789328,0.7817901,0.7846370,0.7874736,0.7903000,0.7931164]
    
    func cpModifier(cp: Double, baseAtt: Int, baseDef: Int, baseStam: Int, indAtt: Int, indDef: Int, indStam: Int) -> Double {
        let numerator = 10 * cp
        let denominator = Double(baseAtt + indAtt) * pow(Double(baseDef + indDef), 0.5) * pow(Double(baseStam + indStam), 0.5)
        return sqrt(numerator / denominator)
    }
    
    func level(cp: Double, baseAtt: Int, baseDef: Int, baseStam: Int, indAtt: Int, indDef: Int, indStam: Int) -> Double {
        let calculatedCpM = cpModifier(cp, baseAtt: baseAtt, baseDef: baseDef, baseStam: baseStam, indAtt: indAtt, indDef: indDef, indStam: indStam)
        
        
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
    
    //    func moveDamage(attack: Double, defense: Double, movePower: Int, stab: Bool, )
}