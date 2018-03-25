//
//  BattleEngine.swift
//  PokemonBattleEngineTest
//
//  Created by Rhys Morgan on 07/01/2018.
//  Copyright © 2018 Rhys Morgan. All rights reserved.
//

import GameplayKit

public struct BattleEngine {
	private let maxTurnCount: Int
	internal(set) public var state: BattleState = .running {
		didSet {
			if state != .running { view?.disableButtons() }
		}
	}
	
	private(set) var winner: Player? {
		didSet {
			guard let winner = winner else { return }
			view?.notifyOfWinner(winner)
			state = .completed
		}
	}
	
	public weak var view: BattleEngineViewer?
	
	private(set) public var playerOne: Player
	private(set) public var playerTwo: Player
	
	private(set) var turnHistory = [Turn]()
	private var turnCounter = 1
	private var lastDamage = 0
	
	private(set) public var weather: Weather = .none {
		didSet {
			switch weather {
			case .none:
				view?.queue(action: .displayText("The weather calmed down"))
			default:
				view?.queue(action: .displayText("The weather became \(weather)"))
			}
			
			view?.display(weather: weather)
		}
	}
	
	var weatherCounter = 0 {
		didSet {
			print("Weather counter = \(weatherCounter)")
			if weatherCounter == 0 {
				weather = .none
			}
		}
	}
	
	private(set) public var terrain: Terrain = .none
	
	var terrainCounter = 0 {
		didSet {
			if terrainCounter == 0 {
				terrain = .none
			}
		}
	}
	
	private var poisonCounter = 1
	
	private var multiHitMoveRunning = false
	private var resolveTurns = false {
		didSet {
			print("resolveTurns was set as \(resolveTurns)")
			if resolveTurns {
				run()
			}
		}
	}
	
	private(set) var turns: [Turn] = [] {
		didSet {
			guard !multiHitMoveRunning else { return }
			
			let containsForceSwitch = !turns.filter {
				if case .forceSwitch(_) = $0.action { return true }
				return false
			}.isEmpty
			
			let containsRun = !turns.filter { $0.action == .run }.isEmpty
			
			if (turns.count == maxTurnCount || containsForceSwitch || containsRun) && !resolveTurns {
				print("resolveTurns set to true")
				resolveTurns = true
			} else if turns.count == 0 {
				resolveTurns = false
			}
		}
	}
	
	private mutating func run() {
		print("---")
		print("Turn \(turnCounter)")
		print("---")
		
		while resolveTurns {
			print("Turns currently sorted as \(turns)")

			turns.sort {
				if $0.priority == $1.priority {
					return $0.playerSpeed > $1.playerSpeed
				} else {
					return $0.priority > $1.priority
				}
			}
			
			print("Turns now sorted as \(turns)")
			
			// Resolving turns
			
			while !turns.isEmpty {
				view?.disableButtons()
				/* 	Lookahead to allow multi-hit moves to be added to the turns array without screwing up weather and terrain counters
					Without this code, when multi-hit moves are used, run() breaks out, and is called again multiple times,
					by resolveTurns's didSet which ends up decrementing the weather and terrain counters
				*/
				if
					let lookahead = turns.first,
					case let .attack(attack) = lookahead.action,
					case .multiHitMove(_,_)? = attack.bonusEffect
				{
					multiHitMoveRunning = true
				}
				
				let turn = turns.removeFirst()
				
				switch turn.action {
				case var .attack(attack):
					var attacker: Pokemon
					var defender: Pokemon

					if turn.player == playerOne {
						attacker = playerOne.activePokemon
						defender = playerTwo.activePokemon
					} else {
						attacker = playerTwo.activePokemon
						defender = playerOne.activePokemon
					}
					
					guard attacker.status != .fainted else { break }
					
					if attacker.volatileStatus.contains(.flinch) {
						view?.queue(action: .displayText("\(attacker) flinched!"))
						attacker.volatileStatus.remove(.flinch)
						break
					}
					
					// Removes .preparingTo(Attack) volatile status, as it's no longer useful here
					if attacker.volatileStatus.contains(.preparingTo(attack.withoutBonusEffect())) {
						attacker.volatileStatus.remove(.preparingTo(attack.withoutBonusEffect()))
					}
					
					print("\(playerOne.name)'s \(playerOne.activePokemon) - Lv. \(playerOne.activePokemon.level) has \(playerOne.activePokemon.currentHP)/\(playerOne.activePokemon.baseStats.hp) HP")
					print("\(playerTwo.name)'s \(playerTwo.activePokemon) - Lv. \(playerTwo.activePokemon.level) has \(playerTwo.activePokemon.currentHP)/\(playerTwo.activePokemon.baseStats.hp) HP")
					
					func doDamage() {
						lastDamage = 0
						
						if attack.category == .status {
							view?.queue(action: .useAttack(attacker: attacker, defender: defender, attack: attack))
						}
						guard attack.power > 0 else { return }
						if case .multiTurnMove(_,_)? = attack.bonusEffect {
							view?.queue(action: .useAttack(attacker: attacker, defender: defender, attack: attack))
							return
						}
						if case .multiHitMove(_,_)? = attack.bonusEffect { return }
						
						if [.physical, .special].contains(attack.category) {
							let (baseDamage, effectiveness) = calculateDamage(attacker: attacker, defender: defender, attack: attack)
							if effectiveness != .notEffective {
								print("\(attack.name) is going to do \(baseDamage) HP of damage against \(defender)")
								defender.damage(baseDamage)
								view?.queue(action: .useAttack(attacker: attacker, defender: defender, attack: attack))
							}
							
							if effectiveness != .normallyEffective {
								view?.queue(action: .displayText(effectiveness.description))
							}
							
							lastDamage = baseDamage
						}
					}
					
					// Have to use a value in .confused(), as you can't do .confused(_) on the right-hand side of an equation
					// but due to .confused's == behaviour, this will return true if it contains *any* .confused(value) where value != 0
					if attacker.volatileStatus.contains(.confused(1)) {
						print("\(attacker.nickname) is confused!")
						let diceRoll = Random.shared.d3Roll()
						if diceRoll == 1 {
							view?.queue(action: .displayText("\(attacker.nickname) hurt itself in its confusion!"))
							let (baseDamage, _) = calculateDamage(attacker: attacker, defender: attacker, attack: Attack(name: "Confused", power: 40, basePP: 1, maxPP: 1, priority: 0, type: .typeless, category: .physical))
							view?.queue(action: .confusedAttack(attacker))
							attacker.damage(baseDamage)
						} else {
							if attacker.volatileStatus.remove(.confused(0)) != nil {
								view?.queue(action: .displayText("\(attacker.nickname) snapped out of it's confusion!"))
							}
							doDamage()
						}
					} else {
						if defender.volatileStatus.contains(.protected) && !attack.breaksProtect {
							view?.queue(action: .displayText("\(defender.nickname) is protected!"))
							break
						} else {
							if case .multiTurnMove(let condition, _)? = attack.bonusEffect, condition(self) {
								attack = attack.withoutBonusEffect()
							}
							doDamage()
						}
					}
					
					func runBonusEffect(attack: Attack, target: Pokemon?) {
						switch attack.bonusEffect {
						case .singleTarget(let bonusEffect)?:
							guard let moveTarget = target else { return }
							bonusEffect(moveTarget)
						case .setWeather(let weather)?:
							setWeather(weather)
						case .setTerrain(let terrain)?:
							setTerrain(terrain)
						case let .multiHitMove(minHits, maxHits)?:
							let numberOfHits = Random.shared.between(minimum: minHits, maximum: maxHits)
							view?.queue(action: .displayText("\(attack.name) will hit \(numberOfHits) times!"))
							let replacementAttack = attack.withoutBonusEffect()
							for _ in 1...numberOfHits {
								turns.insert(Turn(player: turn.player, action: .attack(attack: replacementAttack)), at: turns.startIndex)
							}
						case let .singleTargetUsingDamage(bonusEffect)?:
							guard let moveTarget = target else { return }
							bonusEffect(moveTarget, lastDamage)
						case .multiTurnMove(let condition, let addAttack)?:
							guard let moveTarget = target else { return }
							if !condition(self) {
								addAttack(attack, moveTarget)
							}
						case .none, .instanceOfMultiHit?:
							break
						}
					}
					
					switch attack.effectTarget {
					case .attacker?:
						runBonusEffect(attack: attack, target: attacker)
						print("\(attacker)'s stats are now: \(attacker.baseStats)")
					case .defender?:
						runBonusEffect(attack: attack, target: defender)
					default:
						runBonusEffect(attack: attack, target: nil)
					}

				case .switchTo(let pokemon), .forceSwitch(let pokemon):
					switchPokemon(player: turn.player, pokemon: pokemon)
				case .run:
					if turn.player == playerOne {
						winner = playerTwo
					} else {
						winner = playerOne
					}
					print("\(turn.player.name) has run")
					return
				case .recharge:
					let pokemon = turn.player.activePokemon
					if pokemon.volatileStatus.contains(.mustRecharge) {
						view?.queue(action: .displayText("\(pokemon) must recharge!"))
						pokemon.volatileStatus.remove(.mustRecharge)
						break
					}
				}
				
				multiHitMoveRunning = false
			}
			
			// After turns run
			for player in [playerOne, playerTwo] {
				
				
				if player.activePokemon.status == .poisoned {
					let poisonDamage = Int(ceil(Double(player.activePokemon.baseStats.hp) / 16.0))
					player.activePokemon.damage(poisonDamage)
					view?.queue(action: .statusDamage(.poisoned, player.activePokemon, poisonDamage))
				}
				
				if player.activePokemon.status == .badlyPoisoned {
					let poisonDamage = Int(ceil((Double(poisonCounter) / 16.0) * Double(player.activePokemon.baseStats.hp)))
					player.activePokemon.damage(poisonDamage)
					view?.queue(action: .statusDamage(.badlyPoisoned, player.activePokemon, poisonDamage))
				}
				
				player.activePokemon.volatileStatus.remove(.protected)
				player.activePokemon.volatileStatus.remove(.flinch)
				
				player.activePokemon.volatileStatus = Set(player.activePokemon.volatileStatus.map { $0.turn() })
				
				if player.activePokemon.status == .fainted {
					view?.queue(action: .displayText("\(player.activePokemon) fainted!"))
					view?.queue(action: .fainted(player.activePokemon))
					
					if !player.allFainted {
						state = .awaitingSwitch
					}
				}
			}
			
			print("\(playerOne.name)'s \(playerOne.activePokemon) has \(playerOne.activePokemon.currentHP)/\(playerOne.activePokemon.baseStats.hp) HP")
			print("\(playerTwo.name)'s \(playerTwo.activePokemon) has \(playerTwo.activePokemon.currentHP)/\(playerTwo.activePokemon.baseStats.hp) HP")
			
			weatherCounter -= 1
			terrainCounter -= 1
			
			if playerOne.allFainted { winner = playerTwo }
			if playerTwo.allFainted { winner = playerOne }
			
			multiHitMoveRunning = false
			turnCounter += 1
		}
		
		view?.queue(action: .clear)
		
		
	}
	
	/// Initialiser for the Battle Engine
	///
	/// - Parameters:
	///   - playerOne: Player instance representing the first player
	///   - playerTwo: Player instance representing the second player
	public init(playerOne: Player, playerTwo: Player) {
		self.playerOne = playerOne
		self.playerTwo = playerTwo
		self.maxTurnCount = 2
	}
	
	/// Calculates the damage for an attack, based on the relevant stats from the attacker and defender
	///
	/// - Parameters:
	///   - attacker: The Pokémon using the attack
	///   - defender: The Pokémon on the receiving end of the attack
	///   - attack: The attack being used by `attacker`
	/// - Returns: A tuple containing the damage, and the effectiveness of the attack
	func calculateDamage(attacker: Pokemon, defender: Pokemon, attack: Attack) -> (Int, Type.Effectiveness) {
		let attackerStat: Int
		let defenderStat: Int
		
		print("---")
		
		if attack.category == .physical {
			if attack.name == "Foul Play" {
				attackerStat = defender.modifiedStats.atk
			} else {
				attackerStat = attacker.modifiedStats.atk
			}
			defenderStat = defender.modifiedStats.def
		} else {
			attackerStat = attacker.modifiedStats.spAtk

			if attack.name == "Psyshock" {
				defenderStat = defender.modifiedStats.def
			} else {
				defenderStat = defender.modifiedStats.spDef
			}
		}
		
		let topInnerBrackets = (floor(2 * Double(attacker.level)) / 5 + 2)
		let topOfEquation = floor(floor(Double(topInnerBrackets) * Double(attack.power) * Double(attackerStat)) / Double(defenderStat))
		
		print("Attacker stat = \(attackerStat)")
		print("Defender stat = \(defenderStat)")
		print("Attack Power: \(attack.power)")
		
		let innerBrackets = floor(topOfEquation / 50 + 2)
		
		let rng = Random.shared.battleRNG() / 100
		print("RNG = \(rng)")
		
		if attacker.ability.name == "Protean" {
			attacker.species.typeOne = attack.type
			attacker.species.typeTwo = nil
			view?.queue(action: .abilityActivation(attacker.ability, attacker))
		}
		
		let stab: Double
		if attacker.species.typeOne == attack.type || attacker.species.typeTwo == attack.type {
			if attacker.ability.name == "Adaptability" {
				stab = 2
			} else {
				stab = 1.5
			}
		} else {
			stab = 1
		}
		
		print("STAB = \(stab)")
		
		let typeOneEff = attack.type.typeEffectiveness(recipient: defender.species.typeOne).rawValue
		let typeTwoEff: Double
		if let typeTwo = defender.species.typeTwo {
			typeTwoEff = attack.type.typeEffectiveness(recipient: typeTwo).rawValue
		} else {
			typeTwoEff = 1
		}
		
		let effectiveness: Type.Effectiveness
		let effectivenessMultiplier = typeOneEff * typeTwoEff
		
		switch effectivenessMultiplier {
		case 0.25, 0.5:
			effectiveness = .notVeryEffective
		case 2, 4:
			effectiveness = .superEffective
		case 0:
			effectiveness = .notEffective
		default:
			effectiveness = .normallyEffective
		}

		print("Effectiveness = \(typeOneEff * typeTwoEff)")
		
		let damage = Int(floor(gameFreakRound(floor(Double(innerBrackets) * rng) * stab) * effectivenessMultiplier))
		
		print("Final damage = \(damage)")
		
		print("---")
		
		return (max(1, damage), effectiveness)
	}
	
	public mutating func addTurn(_ turn: Turn) {
		if !turns.isEmpty {
			switch turn.action {
			case .attack(_), .switchTo(_):
				removeTurns(belongingTo: turn.player)
				turns.append(turn)
			default:
				turns.append(turn)
			}
		} else {
			turns.append(turn)
		}
	}
	
	private mutating func switchPokemon(player: Player, pokemon: Pokemon) {
		let switchingPokemon = player.activePokemon
		player.activePokemon = pokemon
		
		switchingPokemon.volatileStatus.removeAll()
		
		view?.queue(action: .switchTo(pokemon, for: player))
		view?.update(with: self)
		state = .running
	}
	
	private mutating func removeTurns(belongingTo player: Player) {
		turns = turns.filter { turn in
			switch turn.action {
			case .attack(_), .switchTo(_):
				return turn.player != player
			default:
				return true
			}
		}
	}
	
	mutating func setWeather(_ weather: Weather) {
		self.weather = weather
		
		weatherCounter = 5
	}
	
	mutating func setTerrain(_ terrain: Terrain) {
		self.terrain = terrain
		
		terrainCounter = 5
	}
	
	public enum BattleState: String, Codable {
		case running, completed, awaitingSwitch
	}
}
