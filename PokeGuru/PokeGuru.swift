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
    private static let pokemonData: [GameDataPokemon] = PokeGuru.getPokemonData()
    private static let moveData: [GameDataMove] = PokeGuru.getMoveData()
    
    public static func pokemon(forId id: Int) -> GameDataPokemon {
        return pokemonData[id - 1]
    }
    
    public static func move(forId id: Int) -> GameDataMove {
        return moveData.filter { $0.id == id }[0]
    }
    
    public static func type(forId id: Int) -> GameDataType {
        return typeData[id - 1]
    }
    
    private static func extractValue<T>(ofkey key: String, fromDict dict: [String: AnyObject?]) -> T? {
        return dict[key] as? T
    }
    
    // takes an array of type ids and returns their corresponding type objects
    private static func lookupTypes(typeIds: [Int]) -> [GameDataType] {
        return typeIds.map { return self.type(forId: $0) }
    }
    
    // convenience method for only looking up one type
    private static func lookupType(typeId: Int) -> GameDataType {
        return lookupTypes([typeId])[0]
    }
    
    private static func getPokemonData() -> [GameDataPokemon] {
        var gameDataPokemons: [GameDataPokemon] = []
        
        let pokemonDataFile = NSDataAsset(name: GAME_DATA_POKEMON, bundle: NSBundle(forClass: self))!.data
        
        let pokemonJson = try! NSJSONSerialization.JSONObjectWithData(pokemonDataFile, options: .AllowFragments)

        for pokemonDict in pokemonJson as! [[String: AnyObject]] {
            let typeIds: [Int] = extractValue(ofkey: "Types", fromDict: pokemonDict)!
            
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
                                quickMoves: extractValue(ofkey: "Quick Moves", fromDict: pokemonDict)!,
                                cinematicMoves: extractValue(ofkey: "Cinematic Moves", fromDict: pokemonDict)!,
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
                             type: lookupType(typeId),
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

