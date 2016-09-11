# PokeGuru
swift library for calculating many different values for pokemon go

## Usage

### Lookup
Lookup GAME_MASTER data for pokemon, moves, and types

```swift
        let bulbasaur = PokeGuru.lookupPokemon(forId: 1)
        let vineWhip = PokeGuru.lookupMove(forId: 214)
        let grass = PokeGuru.lookupType(forId: 5)
```

### Calculate
Calculate stats like total damage output, dps, and effective hp

```swift
        let pokeGuru = PokeGuru(pokemonId: 3, fastMoveId: 214, specialMoveId: 47, cp: 2081,
                                individualAttack: 9, individualDefense: 10, individualStamina: 8)
        print(pokeGuru.tdoOffense)
        print(pokeGuru.tdoDefense)
        print(pokeGuru.dpsCombo)
        print(pokeGuru.dpsFast)
        print(pokeGuru.eHp)
```
