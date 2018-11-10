//
//  PokemonEvolution.swift
//  PokemonKit
//
//  Created by Rhys Morgan on 10/11/2018.
//  Copyright © 2018 Rhys Morgan. All rights reserved.
//

import Foundation

public struct PokemonEvolution {
	let evolvedPokemon: PokemonSpecies
	let condition: Set<EvolutionConditions>
	
	
	public enum EvolutionConditions: Hashable {
		/// Minimum level to evolve
		case levelUp(Int)
		
		/// An item that can be used to evolve a Pokémon
		///
		/// e.g. Moon Stone to evolve Clefairy to Clefable
		case evolutionStone
		
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
		
		/// Evolves when traded while holding a specific item
		///
		/// e.g. Electabuzz must hold the Electirizer to evolve into Electivire
		case tradeWithItem
		
		/// Evolves when traded for a specific Pokémon
		///
		/// e.g. Shelmet must be traded for a Karrablast to evolve into Accelgor
		case tradeForPokemon(PokemonSpecies)
		
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
		public enum TyrogueStats {
			/// Attack is higher than Defense
			case attackHigher
			
			/// Defense is higher than Attack
			case defenseHigher
			
			/// Attack and Defense are equal
			case equal
		}
		
		/// Different versions of Pokémon
		public enum Game {
			/// Pokémon Sun/Ultra Sun
			case sun
			
			/// Pokémon Moon/Ultra Moon
			case moon
		}
		
		/// Special locations, used for evolving certain Pokémon
		public enum Area {
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
	}
}
