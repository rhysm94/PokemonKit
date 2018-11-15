//
//  PokemonEvolution.swift
//  PokemonKit
//
//  Created by Rhys Morgan on 10/11/2018.
//  Copyright © 2018 Rhys Morgan. All rights reserved.
//

import Foundation

public struct PokemonEvolution: Hashable, Codable {
	let evolvedPokemon: PokemonSpecies
	let conditions: Set<EvolutionConditions>
	
    public enum EvolutionConditions: Hashable, Codable {
		/// Minimum level to evolve
		case levelUp(Int)
		
		/// An item that can be used to evolve a Pokémon
		///
		/// e.g. Moon Stone to evolve Clefairy to Clefable
        /// - Note:
        /// When items are implemented, this will need to be changed
        #warning("Change me, when items are implemented")
		case item
		
		/// Must know the associated Attack
		///
		/// e.g. Piloswine must know Ancient Power to evolve into Mamoswine
		case knowsAttack(Attack)
		
		/// Must have learned an Attack of the associated Type
		///
		/// e.g. Eevee must know a Fairy type move to evolve into Sylveon
		case knowsAttackType(Type)
		
		/// Evolves when traded
		///
		/// e.g. To evolve Kadabra to Alakazam
		case trade
		
		/// Evolves when traded for a specific Pokémon
		///
		/// e.g. Shelmet must be traded for a Karrablast to evolve into Accelgor
		case tradeForPokemon(PokemonSpecies)
		
		/// Evolves when levelled up with a specific Pokémon in the party
		///
		/// e.g. To evolve Mantyke to Mantine, there must be a Remoraid in the party
		case levelUpWithPokemonInParty(PokemonSpecies)
		
		/// Evolves when levelled up with Pokémon with the associated type in the party
		///
		/// e.g. To evolve Pancham to Pangoro, there must be a `Type.Dark` Pokémon in the party
		case levelUpWithPokemonOfTypeInParty(Type)
		
		/// Must be levelled up in a specific area
		///
		/// e.g. Magneton must be levelled up in magnetic field (`Area.magneticField`) to evolve into Magnezone
		case levelUpInArea(Area)
		
		/// Must be the specific gender
		///
		/// e.g. Salandit must be `Gender.female` to evolve into Salazzle
		case gender(Gender)
		
		/// Must be the relevant time of day
		///
		/// e.g. Must be `Time.night` to evolve Eevee to Umbreon
		case timeOfDay(Time)
		
		/// Must have high happiness (220 or above) to evolve
		///
		/// Applies to all baby Pokémon, such as Togepi evolving into Togetic
		case happiness
		
		/// Must have a high beauty (170 or above) to evolve
		///
		/// Applies to Milotic in games with Pokémon Contest stats
		case beauty
		
        /// Must have a high affection from Pokémon Amie to evolve
        ///
        /// Applies to Eevee
        case affection
        
		/// Device must be held upside down
		///
		/// e.g. When evolving Inkay to Malamar
		case upsideDown
		
		/// Player must have an empty slot in their party, and a spare Poké Ball
		///
		/// e.g. When evolving Ninjask to Nincada, if this condition is met,
		/// the player will also obtain a Shedinja
		case emptySlot
		
		/// Decides which Pokémon Tyrogue evolves into
		///
		/// - `TyrogueStats.attackHigher`: Tyrogue evolves into Hitmonchan
		/// - `TyrogueStats.defenseHigher`: Tyrogue evolves into Hitmonlee
		/// - `TyrogueStats.equal`: Tyrogue evolves into Hitmontop
		case physicalStats(TyrogueStats)
		
		/// Decides which Pokémon Cosmoem evolves into
		///
		/// Game:
		/// - `Game.sun`: Cosmoem evolves into Solgaleo
		/// - `Game.moon`: Cosmoem evolves into Lunala
		case game(Game)
		
		/// The associated Weather must apply in the overworld for the evolution to occur
		///
		/// e.g. It must be `Weather.rain` in the overworld for Sliggoo to evolve to Goodra
		case weather(Weather)
		
		/// Differences in Tyrogue's stats, to determine which of its evolutions it evolves into
		public enum TyrogueStats: String, Codable, Hashable {
			/// Attack is higher than Defense
			case attackHigher
			
			/// Defense is higher than Attack
			case defenseHigher
			
			/// Attack and Defense are equal
			case equal
		}
		
		/// Different versions of Pokémon
		public enum Game: String, Codable, Hashable {
			/// Pokémon Sun/Ultra Sun
			case sun
			
			/// Pokémon Moon/Ultra Moon
			case moon
		}
		
		/// Special locations, used for evolving certain Pokémon
		public enum Area: String, Codable, Hashable {
			/// Icy Rock
			///
			/// Used to evolve Eevee to Glaceon
			case icyRock
			
			/// Moss Rock
			///
			/// Used to evolve Eevee to Leafeon
			case mossRock
			
			/// Magnetic Field
			///
			/// Used to evolve multiple Pokémon, such as Magneton to Magnezone
			case magneticField
		}
        
        private enum Base: String, Codable {
            case levelUp
            case item
            case knowsAttack
            case knowsAttackType
            case trade
            case tradeForPokemon
            case levelUpWithPokemonInParty
            case levelUpWithPokemonOfTypeInParty
            case levelUpInArea
            case gender
            case timeOfDay
            case happiness
            case beauty
            case affection
            case upsideDown
            case emptySlot
            case physicalStats
            case game
            case weather
        }
        
        private enum CodingKeys: CodingKey {
            case base
            case level
            case attack
            case type
            case pokemon
            case area
            case gender
            case time
            case stats
            case game
            case weather
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let base = try container.decode(Base.self, forKey: .base)
            
            switch base {
            case .levelUp:
                let level = try container.decode(Int.self, forKey: .level)
                self = .levelUp(level)
            case .item:
                self = .item
            case .knowsAttack:
                let attack = try container.decode(Attack.self, forKey: .attack)
                self = .knowsAttack(attack)
            case .knowsAttackType:
                let type = try container.decode(Type.self, forKey: .type)
                self = .knowsAttackType(type)
            case .trade:
                self = .trade
            case .tradeForPokemon:
                let pokemon = try container.decode(PokemonSpecies.self, forKey: .pokemon)
                self = .tradeForPokemon(pokemon)
            case .levelUpWithPokemonInParty:
                let pokemon = try container.decode(PokemonSpecies.self, forKey: .pokemon)
                self = .levelUpWithPokemonInParty(pokemon)
            case .levelUpWithPokemonOfTypeInParty:
                let type = try container.decode(Type.self, forKey: .type)
                self = .levelUpWithPokemonOfTypeInParty(type)
            case .levelUpInArea:
                let area = try container.decode(Area.self, forKey: .area)
                self = .levelUpInArea(area)
            case .gender:
                let gender = try container.decode(Gender.self, forKey: .gender)
                self = .gender(gender)
            case .timeOfDay:
                let time = try container.decode(Time.self, forKey: .time)
                self = .timeOfDay(time)
            case .happiness:
                self = .happiness
            case .beauty:
                self = .beauty
            case .affection:
                self = .affection
            case .upsideDown:
                self = .upsideDown
            case .emptySlot:
                self = .emptySlot
            case .physicalStats:
                let stats = try container.decode(TyrogueStats.self, forKey: .stats)
                self = .physicalStats(stats)
            case .game:
                let game = try container.decode(Game.self, forKey: .game)
                self = .game(game)
            case .weather:
                let weather = try container.decode(Weather.self, forKey: .weather)
                self = .weather(weather)
            }
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            
            switch self {
            case .levelUp(let level):
                try container.encode(Base.levelUp, forKey: .base)
                try container.encode(level, forKey: .level)
            case .item:
                try container.encode(Base.item, forKey: .base)
            case .knowsAttack(let attack):
                try container.encode(Base.knowsAttack, forKey: .base)
                try container.encode(attack, forKey: .attack)
            case .knowsAttackType(let type):
                try container.encode(Base.knowsAttackType, forKey: .base)
                try container.encode(type, forKey: .type)
            case .trade:
                try container.encode(Base.trade, forKey: .base)
            case .tradeForPokemon(let pokemon):
                try container.encode(Base.tradeForPokemon, forKey: .base)
                try container.encode(pokemon, forKey: .pokemon)
            case .levelUpWithPokemonInParty(let pokemon):
                try container.encode(Base.levelUpWithPokemonInParty, forKey: .base)
                try container.encode(pokemon, forKey: .pokemon)
            case .levelUpWithPokemonOfTypeInParty(let type):
                try container.encode(Base.levelUpWithPokemonOfTypeInParty, forKey: .base)
                try container.encode(type, forKey: .type)
            case .levelUpInArea(let area):
                try container.encode(Base.levelUpInArea, forKey: .base)
                try container.encode(area, forKey: .area)
            case .gender(let gender):
                try container.encode(Base.gender, forKey: .base)
                try container.encode(gender, forKey: .gender)
            case .timeOfDay(let time):
                try container.encode(Base.timeOfDay, forKey: .base)
                try container.encode(time, forKey: .time)
            case .happiness:
                try container.encode(Base.happiness, forKey: .base)
            case .beauty:
                try container.encode(Base.beauty, forKey: .base)
            case .affection:
                try container.encode(Base.affection, forKey: .base)
            case .upsideDown:
                try container.encode(Base.upsideDown, forKey: .base)
            case .emptySlot:
                try container.encode(Base.emptySlot, forKey: .base)
            case .physicalStats(let stats):
                try container.encode(Base.physicalStats, forKey: .base)
                try container.encode(stats, forKey: .stats)
            case .game(let game):
                try container.encode(Base.game, forKey: .base)
                try container.encode(game, forKey: .game)
            case .weather(let weather):
                try container.encode(Base.weather, forKey: .base)
                try container.encode(weather, forKey: .weather)
            }
        }
	}
}
