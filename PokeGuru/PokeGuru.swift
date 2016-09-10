//
//  PokeMath.swift
//  PokeMath
//
//  Created by Brian Barton on 9/6/16.
//  Copyright © 2016 Brian Barton. All rights reserved.
//

import Foundation

public class PokeGuru {
    private static let GAME_DATA_POKEMON = "GAME_DATA_POKEMON"
    private static let GAME_DATA_MOVES = "GAME_DATA_MOVES"
    private static let GAME_DATA_TYPES = "GAME_DATA_TYPES"

    private static let typeData: [GameDataType] = PokeGuru.getTypeData()
    private static let moveData: [GameDataMove] = PokeGuru.getMoveData()
    private static let pokemonData: [GameDataPokemon] = PokeGuru.getPokemonData()
    
    private static let pokeMath = PokeMath()
    
    private let cp: Double
    private let individualAttack: Double
    private let individualDefense: Double
    private let individualStamina: Double
    
    private let cpModifier: Double
    private let attack: Double
    private let defense: Double
    private let hp: Double
    private let h_xy: Double

    private let eHpDefense: Double
    private let eHp: Double
    
    public let pokemon: GameDataPokemon
    public let fastMove: GameDataMove
    public let specialMove: GameDataMove
    
    public let dpsFast: Double
    public let dpsCombo: Double
    public let dpsDefense: Double

    public let tdoOffense: Double
    public let tdoDefense: Double
    public let offensiveEfficiency: Double
    public let defensiveEfficiency: Double
    
    public var uselessSpecial: Bool { get { return dpsFast >= dpsCombo } }
    
    public init(pokemonId: Int, fastMoveId: Int, specialMoveId: Int, cp: Int,
         individualAttack: Int, individualDefense: Int, individualStamina: Int) {
        self.pokemon = PokeGuru.lookupPokemon(forId: pokemonId)
        self.fastMove = PokeGuru.lookupMove(forId: fastMoveId)
        self.specialMove = PokeGuru.lookupMove(forId: specialMoveId)
        self.cp = Double(cp)
        self.individualAttack = Double(individualAttack)
        self.individualDefense = Double(individualDefense)
        self.individualStamina = Double(individualStamina)
        
        let pokeMath = PokeMath()
        
        self.cpModifier = pokeMath.calcCpModifier(self.cp, baseAtt: Double(pokemon.baseAttack), baseDef: Double(pokemon.baseDefense),
                                                           baseStam: Double(pokemon.baseStamina), indAtt: self.individualAttack,
                                                           indDef: self.individualDefense, indStam: self.individualStamina)
        
        self.attack = pokeMath.calcStat(Double(pokemon.baseAttack), individualStat: self.individualAttack, cpModifier: cpModifier)
        self.defense = pokeMath.calcStat(Double(pokemon.baseDefense), individualStat: self.individualDefense, cpModifier: cpModifier)
        self.hp = floor(pokeMath.calcStat(Double(pokemon.baseStamina), individualStat: self.individualStamina, cpModifier: cpModifier))
        self.h_xy = pokeMath.calcNumHits(hp, defense: defense)
        self.eHp = pokeMath.calcEHp(hp, h_xy: h_xy, defense: defense)
        self.eHpDefense = pokeMath.calcEHpDef(hp, h_xy: h_xy, defense: defense)

        var tdoTuple = PokeGuru.calcTdo(attack, hp: hp, eHp: eHp, eHpDef: eHpDefense, fastMove: fastMove, specialMove: specialMove, pokemon: pokemon)

        self.tdoOffense = tdoTuple.tdoOff
        self.tdoDefense = tdoTuple.tdoDef
        self.dpsFast = tdoTuple.dpsFast
        self.dpsCombo = tdoTuple.dpsCombo
        self.dpsDefense = tdoTuple.dpsDef
        
        // determine the top offensive and defensive move sets for this pokemon
        var maxTdoOffense = tdoOffense
        var maxTdoDefense = tdoDefense

        for fm in pokemon.quickMoves {
            for sm in pokemon.cinematicMoves {
                tdoTuple = PokeGuru.calcTdo(attack, hp: hp, eHp: eHp, eHpDef: eHpDefense,
                                                fastMove: fm, specialMove: sm, pokemon: pokemon)

                if tdoTuple.tdoDef > maxTdoDefense {
                    maxTdoDefense = tdoTuple.tdoDef
                }
                if tdoTuple.tdoOff > maxTdoOffense {
                    maxTdoOffense = tdoTuple.tdoOff
                }
            }
        }
        
        self.offensiveEfficiency = tdoOffense / maxTdoOffense
        self.defensiveEfficiency = tdoDefense / maxTdoDefense
    }
    
    // takes a pokemon id and returns the corresponding pokemon object
    public static func lookupPokemon(forId id: Int) -> GameDataPokemon {
        return pokemonData[id - 1]
    }
    
    // takes a move id and returns the corresponding move object
    public static func lookupMove(forId id: Int) -> GameDataMove {
        return moveData.filter { $0.id == id }[0]
    }
    
    // takes a type id and returns the corresponding type object
    public static func lookupType(forId id: Int) -> GameDataType {
        return typeData[id - 1]
    }
    
    private static func calcTdo(attack: Double, hp: Double, eHp: Double, eHpDef: Double, fastMove: GameDataMove,
                                specialMove: GameDataMove, pokemon: GameDataPokemon)
                            -> (tdoOff: Double, tdoDef: Double, dpsFast: Double, dpsCombo: Double, dpsDef: Double) {
        let fDmg = pokeMath.calcFDmg(attack, fPwr: Double(fastMove.power),
                                      stab: PokeGuru.calcStab(pokemon, move: fastMove, value: pokeMath.STAB))
        let fDur = Double(fastMove.duration) / 1000.0
        let fEng = Double(fastMove.energyDelta)
        let sDmg = pokeMath.calcSDmg(attack, sPwr: Double(specialMove.power),
                                      stab: PokeGuru.calcStab(pokemon, move: fastMove, value: pokeMath.STAB))
        let sDur = Double(specialMove.duration) / 1000.0
        let sC = pokeMath.calcSc(specialMove.energyDelta)
        let eReq = pokeMath.calcEReqOff(hp, eHp: eHp, fEng: fEng, fDur: fDur, sDur: sDur, sC: sC)
        let dpsFast = pokeMath.calcDpsFast(fDmg, fDur: fDur)
        let dpsCombo = pokeMath.calcDpsCombo(eReq, fEng: fEng, fDmg: fDmg, sDmg: sDmg, fDur: fDur, sDur: sDur, sC: sC)
        let dpsMax = max(dpsFast, dpsCombo)
        let dpsDef = pokeMath.calcDpsDef(hp, eHp: eHp, fEng: fEng, fDur: fDur, sDur: sDur, sC: sC, fDmg: fDmg, sDmg: sDmg)
        let tdoOff = pokeMath.calcOffTdo(dpsMax, eHp: eHp)
        let tdoDef = pokeMath.calcDefTdo(dpsDef, eHpDef: eHpDef)
        
        return (tdoOff, tdoDef, dpsFast, dpsCombo, dpsDef)
    }
    
    private static func calcStab(pokemon: GameDataPokemon, move: GameDataMove, value: Double) -> Double {
        return pokemon.types.contains(move.type) ? value : 1.0
    }
    
    // takes an array of type ids and returns their corresponding type objects
    private static func lookupTypes(typeIds: [Int]) -> [GameDataType] {
        return typeIds.map { return self.lookupType(forId: $0) }
    }
    
    // takes an array of move ids and returns their corresponding move objects
    private static func lookupMoves(moveIds: [Int]) -> [GameDataMove] {
        return moveIds.map { return self.lookupMove(forId: $0 ) }
    }
    
    private static func extractValue<T>(ofkey key: String, fromDict dict: [String: AnyObject?]) -> T? {
        return dict[key] as? T
    }
    
    private static func getPokemonData() -> [GameDataPokemon] {
        var gameDataPokemons: [GameDataPokemon] = []
        
        let pokemonDataFile = NSDataAsset(name: GAME_DATA_POKEMON, bundle: NSBundle(forClass: self))!.data
        
        let pokemonJson = try! NSJSONSerialization.JSONObjectWithData(pokemonDataFile, options: .AllowFragments)

        for pokemonDict in pokemonJson as! [[String: AnyObject]] {
            let typeIds: [Int] = extractValue(ofkey: "Types", fromDict: pokemonDict)!
            let quickMoveIds: [Int] = extractValue(ofkey: "Quick Moves", fromDict: pokemonDict)!
            let cinematicMoveIds: [Int] = extractValue(ofkey: "Cinematic Moves", fromDict: pokemonDict)!
            
            let gameDataPokemon =
                GameDataPokemon(id: extractValue(ofkey: "ID", fromDict: pokemonDict)!,
                                name: extractValue(ofkey: "Name", fromDict: pokemonDict)!,
                                types: lookupTypes(typeIds),
                                baseStamina: extractValue(ofkey: "Base Stamina", fromDict: pokemonDict)!,
                                baseAttack: extractValue(ofkey: "Base Attack", fromDict: pokemonDict)!,
                                baseDefense: extractValue(ofkey: "Base Defense", fromDict: pokemonDict)!,
                                maxCP: extractValue(ofkey: "Max CP", fromDict: pokemonDict)!,
                                height: extractValue(ofkey: "Height (Meters)", fromDict: pokemonDict)!,
                                weight: extractValue(ofkey: "Weight (Kg)", fromDict: pokemonDict)!,
                                heightStdDev: extractValue(ofkey: "Height StdDev", fromDict: pokemonDict)!,
                                weightStdDev: extractValue(ofkey: "Weight StdDev", fromDict: pokemonDict)!,
                                baseCaptureRate: extractValue(ofkey: "Base Capture Rate", fromDict: pokemonDict)!,
                                baseFleeRate: extractValue(ofkey: "Base Flee Rate", fromDict: pokemonDict)!,
                                collisionRadius: extractValue(ofkey: "Collision Radius (Meters)", fromDict: pokemonDict)!,
                                collisionHeight: extractValue(ofkey: "Collision Height (Meters)", fromDict: pokemonDict)!,
                                collisionHeadRadius: extractValue(ofkey: "Collision Head Radius (Meters)", fromDict: pokemonDict)!,
                                movementType: extractValue(ofkey: "Movement Type", fromDict: pokemonDict)!,
                                movementTimer: extractValue(ofkey: "Movement Timer (Sec)", fromDict: pokemonDict)!,
                                jumpTime: extractValue(ofkey: "Jump Time (Sec)", fromDict: pokemonDict)!,
                                attackTimer: extractValue(ofkey: "Attack Timer (Sec)", fromDict: pokemonDict)!,
                                quickMoves: lookupMoves(quickMoveIds),
                                cinematicMoves: lookupMoves(cinematicMoveIds),
                                animationTime: extractValue(ofkey: "Animation Time", fromDict: pokemonDict)!,
                                evolution: extractValue(ofkey: "Evolution", fromDict: pokemonDict),
                                evolutionPips: extractValue(ofkey: "Evolution Pips", fromDict: pokemonDict)!,
                                pokemonClass: extractValue(ofkey: "Pokemon Class", fromDict: pokemonDict)!,
                                familyId: extractValue(ofkey: "Family Id", fromDict: pokemonDict)!,
                                candyToEvolve: extractValue(ofkey: "Candy To Evolve", fromDict: pokemonDict)!)
            
            gameDataPokemons.append(gameDataPokemon)
        }
        
        return gameDataPokemons
    }
    
    private static func getMoveData() -> [GameDataMove] {
        var gameDataMoves: [GameDataMove] = []
        
        let movesDataFile = NSDataAsset(name: GAME_DATA_MOVES, bundle: NSBundle(forClass: self))!.data
        
        let movesJson = try! NSJSONSerialization.JSONObjectWithData(movesDataFile, options: .AllowFragments)
        
        for movesDict in movesJson as! [[String: AnyObject]] {
            let typeId: Int = extractValue(ofkey: "Type", fromDict: movesDict)!
            
            let gameDataMove =
                GameDataMove(id: extractValue(ofkey: "ID", fromDict: movesDict)!,
                             name: extractValue(ofkey: "Name", fromDict: movesDict)!,
                             moveType: extractValue(ofkey: "Move Type", fromDict: movesDict)!,
                             animationId: extractValue(ofkey: "Animation ID", fromDict: movesDict)!,
                             type: lookupType(forId: typeId),
                             power: extractValue(ofkey: "Power", fromDict: movesDict) ?? 0,
                             accuracyChance: extractValue(ofkey: "Accuracy Chance", fromDict: movesDict)!,
                             staminaLossScalar: extractValue(ofkey: "Stamina Loss Scalar", fromDict: movesDict) ?? 0,
                             trainerLevelMin: extractValue(ofkey: "Trainer Level Min", fromDict: movesDict)!,
                             trainerLevelMax: extractValue(ofkey: "Trainer Level Max", fromDict: movesDict)!,
                             duration: extractValue(ofkey: "Duration (ms)", fromDict: movesDict)!,
                             damageWindowStart: extractValue(ofkey: "Damage Window Start (ms)", fromDict: movesDict)!,
                             damageWindowEnd: extractValue(ofkey: "Damage Window End (ms)", fromDict: movesDict)!,
                             energyDelta: extractValue(ofkey: "Energy Delta", fromDict: movesDict)!,
                             criticalChance: extractValue(ofkey: "Critical Chance", fromDict: movesDict) ?? 0)
            
            gameDataMoves.append(gameDataMove)
        }
        
        return gameDataMoves
    }
    
    private static func getTypeData() -> [GameDataType] {
        var gameDataTypes: [GameDataType] = []
        
        let typesDataFile = NSDataAsset(name: GAME_DATA_TYPES, bundle: NSBundle(forClass: self))!.data
        
        let typesJson = try! NSJSONSerialization.JSONObjectWithData(typesDataFile, options: .AllowFragments)
        
        for typesDict in typesJson as! [[String: AnyObject]] {
            let gameDataType =
                GameDataType(id: extractValue(ofkey: "ID", fromDict: typesDict)!,
                             name: extractValue(ofkey: "Name", fromDict: typesDict)!,
                             effective: extractValue(ofkey: "Effective", fromDict: typesDict)!,
                             notEffective: extractValue(ofkey: "Not Effective", fromDict: typesDict)!,
                             noEffect: extractValue(ofkey: "No Effect", fromDict: typesDict)!)
            
            gameDataTypes.append(gameDataType)
        }
        
        return gameDataTypes
    }
}

