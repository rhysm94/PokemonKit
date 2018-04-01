//
//  BattleEngine.swift
//  PokemonBattleEngineTest
//
//  Created by Rhys Morgan on 07/01/2018.
//  Copyright © 2018 Rhys Morgan. All rights reserved.
//

import GameplayKit

public class BattleEngine: NSObject, GKGameModel {
	private let maxTurnCount: Int
	internal(set) public var state: BattleState = .running {
		didSet {
			if state != .running { view?.disableButtons() }
		}
	}
	
	private(set) var winner: Player? {
		didSet {
			guard let winner = winner else { return }
			print("Setting winner as \(winner)")
			print("Player One all fainted? \(playerOne.allFainted)")
			print("Player Two all fainted? \(playerTwo.allFainted)")
			view?.queue(action: .notifyOfWinner(winner))
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
			view?.queue(action: .weatherUpdate(weather))
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
	
	private(set) public var terrain: Terrain = .none {
		didSet {
			view?.queue(action: .terrainUpdate(terrain))
		}
	}
	
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
	
	private func run() {
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
				turnHistory.append(turn)
				
				switch turn.action {
				case var .attack(attack):
					var attacker: Pokemon
					var defender: Pokemon

					
					if turn.player.playerId == playerOne.playerId {
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
						
						// Skips doing damage if this is the first half of a multi-turn move, but still queues the relevant .useAttack
						if case .multiTurnMove(_,_)? = attack.bonusEffect {
							view?.queue(action: .useAttack(attacker: attacker, defender: defender, attack: attack))
							return
						}
						
						// Skips doing damage if this is the first instance of a multi-hit move
						if case .multiHitMove(_,_)? = attack.bonusEffect {
							return
						}
						
						switch attack.category {
						case .physical, .special:
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
						case .status:
							print("\(attacker) is going to use \(attack.name) against \(defender)")
							view?.queue(action: .useAttack(attacker: attacker, defender: defender, attack: attack))
						}
					}
					
					func successfulDamage() {
						if case .multiTurnMove(let condition, _)? = attack.bonusEffect, condition(self) {
							attack = attack.withoutBonusEffect()
						}
						
						doDamage()
						
					}
					
					// Have to use a value in .confused(), as you can't do .confused(_) on the right-hand side of an equation
					// but due to .confused's == behaviour, this will return true if it contains *any* .confused(value) where value != 0
					
					func confusionCheck() -> Bool {
						if attacker.volatileStatus.contains(.confused(1)) {
							print("\(attacker.nickname) is confused!")
							let diceRoll = Random.shared.d3Roll()
							if diceRoll == 1 {
								view?.queue(action: .displayText("\(attacker.nickname) hurt itself in its confusion!"))
								print("\(attacker.nickname) hurt itself in its confusion!")
								
								let (baseDamage, _) = calculateDamage(attacker: attacker, defender: attacker, attack: Attack(name: "Confused", power: 40, basePP: 1, maxPP: 1, priority: 0, type: .typeless, category: .physical))
								view?.queue(action: .confusedAttack(attacker))
								attacker.damage(baseDamage)
								return false
							} else {
								if attacker.volatileStatus.remove(.confused(0)) != nil {
									view?.queue(action: .displayText("\(attacker.nickname) snapped out of it's confusion!"))
								}
								return true
							}
						} else {
							return true
						}
					}
					
					func paralysisCheck() -> Bool {
						if attacker.status == .paralysed {
							let diceRoll = Random.shared.d3Roll()
							if diceRoll == 1 {
								view?.queue(action: .displayText("\(attacker) is paralysed"))
								return false
							} else {
								return true
							}
						} else {
							return true
						}
					}
					
					func protectedCheck() -> Bool {
						if defender.volatileStatus.contains(.protected) && !attack.breaksProtect {
							return false
						} else {
							return true
						}
					}
					
					func hitCheck() -> Bool {
						if let accuracy = attack.accuracy {
							let hit = Random.shared.shouldHit(chance: accuracy)
							if !hit {
								view?.queue(action: .displayText("\(attacker.nickname) missed!"))
							}
							return hit
						} else {
							return true
						}
					}
					
					let shouldAttack = [confusionCheck(), paralysisCheck(), protectedCheck(), hitCheck()].reduce(true) { $0 && $1 }
					
					if shouldAttack {
						successfulDamage()
					} else {
						break
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
	public required init(playerOne: Player, playerTwo: Player) {
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
	
	public func addTurn(_ turn: Turn) {
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
		
		if turn.player.playerId == playerOne.playerId {
			activePlayer = playerTwo
		} else {
			activePlayer = playerOne
		}
	}
	
	private func switchPokemon(player: Player, pokemon: Pokemon) {
		var switchingPlayer: Player
		
		if player.playerId == playerOne.playerId {
			switchingPlayer = playerOne
		} else {
			switchingPlayer = playerTwo
		}
		
		let switchingPokemon = switchingPlayer.activePokemon
		switchingPlayer.activePokemon = pokemon
		
		switchingPokemon.volatileStatus.removeAll()
		
		view?.queue(action: .switchTo(pokemon, for: player))
		view?.update(with: self)
		state = .running
	}
	
	private func removeTurns(belongingTo player: Player) {
		turns = turns.filter { turn in
			switch turn.action {
			case .attack(_), .switchTo(_):
				return turn.player != player
			default:
				return true
			}
		}
	}
	
	func setWeather(_ weather: Weather) {
		self.weather = weather
		
		weatherCounter = 5
	}
	
	func setTerrain(_ terrain: Terrain) {
		self.terrain = terrain
		
		terrainCounter = 5
	}
	
	public enum BattleState: String, Codable {
		case running, completed, awaitingSwitch
	}
	
	// MARK:- GameplayKit Methods
	
	public var players: [GKGameModelPlayer]? {
		return [playerOne, playerTwo]
	}
	
	public lazy var activePlayer: GKGameModelPlayer? = {
		return self.playerOne
	}()
	
	public func setGameModel(_ gameModel: GKGameModel) {
		let model = gameModel as! BattleEngine
		
		self.state = model.state
		if let winner = model.winner {
			self.winner = Player(player: winner)
		}
		
		self.playerOne = Player(player: model.playerOne)
		self.playerTwo = Player(player: model.playerTwo)
		
		self.turnHistory = model.turnHistory
		
		self.turnCounter = model.turnCounter
		
		self.lastDamage = model.lastDamage
		
		self.weather = model.weather
		self.weatherCounter = model.weatherCounter
		
		self.terrain = model.terrain
		self.terrainCounter = model.terrainCounter
		
		self.multiHitMoveRunning = model.multiHitMoveRunning

		self.resolveTurns = model.resolveTurns
		self.turns = model.turns
		
		self.poisonCounter = model.poisonCounter
		self.activePlayer = model.activePlayer
	}
	
	public func score(for player: GKGameModelPlayer) -> Int {
		
		var score = 0
		
		guard let player = player as? Player else { return .min }
		
		let opponent: Player
		if player.playerId == playerOne.playerId {
			opponent = playerTwo
		} else {
			opponent = playerOne
		}
		
		guard player.playerId == playerOne.playerId || player.playerId == playerTwo.playerId else { return .min }
		
		func scoreValue(for number: Double) -> Int {
			switch number {
			case 0.9..<1: return 10
			case 0.8..<0.9: return 20
			case 0.7..<0.8: return 30
			case 0.6..<0.7: return 40
			case 0.5..<0.6: return 50
			case 0.4..<0.5: return 60
			case 0.3..<0.4: return 70
			case 0.2..<0.3: return 80
			case 0.1..<0.2: return 90
			case 0: return 100
			default: return -10
			}
		}
		
		score += scoreValue(for: Double(opponent.activePokemon.currentHP) / Double(opponent.activePokemon.baseStats.hp))
		
		score -= scoreValue(for: Double(player.activePokemon.currentHP) / Double(player.activePokemon.baseStats.hp))
		
		if player.activePokemon.status == .fainted {
			score -= 100
		}
		
		if !player.activePokemon.volatileStatus.isEmpty {
			for status in player.activePokemon.volatileStatus {
				switch status {
				case .confused(let counter):
					if counter > 0 {
						score -= 20
					}
				case .protected:
					score += 40
				case .flinch:
					score -= 30
				case .mustRecharge:
					score -= 20
				case .preparingTo(_):
					score -= 20
				}
			}
		}
		
		if isWin(for: player) {
			score += 500
		} else if isWin(for: opponent) {
			score -= 500
		}
		
		print("Score for state = \(score)")
		return score
	}
	
	public func gameModelUpdates(for player: GKGameModelPlayer) -> [GKGameModelUpdate]? {
		
		var possibleTurns: [Turn]?
		
		if let player = player as? Player {
			
			possibleTurns = [Turn]()
			
			switch state {
			case .running:
				if player.activePokemon.status != .fainted {
					for status in player.activePokemon.volatileStatus {
						switch status {
						case .mustRecharge:
							possibleTurns?.append(Turn(player: player, action: .recharge))
							return possibleTurns
						case .preparingTo(let attack):
							possibleTurns?.append(Turn(player: player, action: .attack(attack: attack.withoutBonusEffect())))
							return possibleTurns
						default: break
						}
					}
					
					for attack in player.activePokemon.attacks {
						possibleTurns?.append(Turn(player: player, action: .attack(attack: attack)))
					}
					
					for pokemon in player.team where pokemon.status != .fainted && pokemon != player.activePokemon {
						possibleTurns?.append(Turn(player: player, action: .switchTo(pokemon)))
					}
				}
			case .completed:
				return nil
			case .awaitingSwitch:
				if player.activePokemon.status == .fainted {
					if !player.allFainted {
						for pokemon in player.team where pokemon.status != .fainted {
							possibleTurns?.append(Turn(player: player, action: .forceSwitch(pokemon)))
						}
					} else {
						return nil
					}
				}
			}
		}
		
		return possibleTurns
	}
	
	public func apply(_ gameModelUpdate: GKGameModelUpdate) {
		if let turn = gameModelUpdate as? Turn {
			self.addTurn(turn)
		} else {
			print("Failure")
		}
	}
	
	public func copy(with zone: NSZone? = nil) -> Any {
		let copy = type(of: self).init(playerOne: playerOne, playerTwo: playerTwo)
		
		copy.setGameModel(self)
		
		return copy
	}
	
	public static func ==(lhs: BattleEngine, rhs: BattleEngine) -> Bool {
		let value =
			lhs.playerOne == rhs.playerOne &&
				lhs.playerTwo == rhs.playerTwo &&
				lhs.weather == rhs.weather &&
				lhs.weatherCounter == rhs.weatherCounter &&
				lhs.terrain == rhs.terrain &&
				lhs.turns == rhs.turns &&
				lhs.terrainCounter == rhs.terrainCounter &&
				lhs.turnCounter == rhs.turnCounter &&
				lhs.lastDamage == rhs.lastDamage &&
				lhs.winner == rhs.winner &&
				lhs.poisonCounter == rhs.poisonCounter
		
		return value
	}
	
	public static func !=(lhs: BattleEngine, rhs: BattleEngine) -> Bool {
		return !(lhs == rhs)
	}
	
	public func isWin(for player: GKGameModelPlayer) -> Bool {
		if let winner = winner {
			return winner == player
		} else {
			return false
		}
	}
	
	public func isLoss(for player: GKGameModelPlayer) -> Bool {
		if let winner = winner {
			return winner != player
		} else {
			return false
		}
	}
	
}
