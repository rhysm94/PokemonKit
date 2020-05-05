//
//  BattleEngine.swift
//  PokemonBattleEngineTest
//
//  Created by Rhys Morgan on 07/01/2018.
//  Copyright © 2018 Rhys Morgan. All rights reserved.
//

import GameplayKit

/// BattleEngine is the internal representation of a Pokémon battle.
///
/// One BattleEngine runs one single battle between two players.
///
/// A BattleEngine object can only be instantiated via `BattleEngine.init(playerOne:playerTwo:)`
public class BattleEngine: NSObject, GKGameModel {
	private let maxTurnCount: Int

	/// Current state of the battle.
	///
	/// When set to anything other than `BattleState.running`,
	/// `BattleEngineViewer.disableButtons()` will be called on `view`
	public internal(set) var state: BattleState = .running {
		didSet {
			if state != .running { view?.disableButtons() }
		}
	}

	private(set) var winner: Player? {
		didSet {
			guard let winner = winner else { return }
			print("Setting winner as \(winner.name)")
			print("Player One all fainted? \(playerOne.allFainted)")
			print("Player Two all fainted? \(playerTwo.allFainted)")
			view?.queue(action: .notifyOfWinner(winner))
			state = .completed
		}
	}

	public weak var view: BattleEngineViewer?

	/// Object representing the first player
	public private(set) var playerOne: Player

	/// Object representing the second player
	public private(set) var playerTwo: Player

	private(set) var turnHistory = [Turn]()
	private var turnCounter = 1
	private var lastDamage = 0

	/// The battle's current `Weather` effect. Default is `Weather.none`.
	///
	/// When set, a `BattleAction.weatherUpdate(_:)` or `BattleAction.displayText(_:)` will be queued on the `view`
	public internal(set) var weather: Weather = .none {
		didSet {
			switch weather {
			case .none:
				view?.queue(action: .displayText(oldValue.disappearMessage))
			default:
				view?.queue(action: .weatherUpdate(weather))
			}
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

	/// The battle's current `Terrain` effect. Default is `Weather.none`.
	public internal(set) var terrain: Terrain = .none {
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
				if case .forceSwitch = $0.action { return true }
				return false
			}.isEmpty

			let containsRun = !turns.filter { $0.action == .run }.isEmpty

			if turns.count == maxTurnCount || containsForceSwitch || containsRun, !resolveTurns {
				print("resolveTurns set to true")
				resolveTurns = true
			} else if turns.count == 0 {
				resolveTurns = false
			}
		}
	}

	/// Sorts turns into the correct order to resolve turns
	private func sortTurns() {
		turns.sort {
			if $0.priority == $1.priority {
				return $0.playerSpeed > $1.playerSpeed
			} else {
				return $0.priority > $1.priority
			}
		}
	}

	private func applyDamage(attacker: Pokemon, defender: Pokemon, attack: Attack) {
		lastDamage = 0

		// Skips doing damage if this is the first half of a multi-turn move, but still queues the relevant .useAttack
		if case .multiTurnMove? = attack.bonusEffect {
			view?.queue(action: .useAttack(attacker: attacker, defender: defender, attack: attack))
			return
		}

		// Skips doing damage if this is the first instance of a multi-hit move
		if case .multiHitMove? = attack.bonusEffect {
			return
		}

		switch attack.category {
		case .physical, .special:
			let (baseDamage, effectiveness) = calculateDamage(attacker: attacker, defender: defender, attack: attack)
			let weatherBlocked = weather.blocks(type: attack.type)

			if effectiveness != .notEffective, !weatherBlocked {
				print("\(attack.name) is going to do \(baseDamage) HP of damage against \(defender)")
				defender.damage(max(1, baseDamage))
				view?.queue(action: .useAttack(attacker: attacker, defender: defender, attack: attack))
			} else if weatherBlocked {
				lastDamage = 0
				guard let message = weather.blockMessage else { break }
				view?.queue(action: .displayText(message))
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

	private func successfulDamage(attacker: Pokemon, defender: Pokemon, attack: Attack) {
		var attack = attack

		// If the condition for a multi-turn move is matched, use it immediately
		// (e.g. in the case of Solar Beam, if the weather is sunny)
		if case let .multiTurnMove(condition, _)? = attack.bonusEffect, condition(self) {
			attack = attack.withoutBonusEffect()
		}

		applyDamage(attacker: attacker, defender: defender, attack: attack)
	}

	private func runBonusEffect(attack: Attack, target: Pokemon? = nil, player: Player) {
		switch attack.bonusEffect {
		case let .singleTarget(bonusEffect)?:
			guard let moveTarget = target else { return }
			bonusEffect(moveTarget)

		case let .setWeather(weather)?:
			setWeather(weather)

		case let .setTerrain(terrain)?:
			setTerrain(terrain)

		case let .multiHitMove(minHits, maxHits)?:
			let numberOfHits = Random.shared.between(minimum: minHits, maximum: maxHits)
			view?.queue(action: .displayText("\(attack.name) will hit \(numberOfHits) times!"))
			let replacementAttack = attack.withoutBonusEffect()
			for _ in 1 ... numberOfHits {
				turns.insert(Turn(player: player, action: .attack(attack: replacementAttack)), at: turns.startIndex)
			}

		case let .singleTargetUsingDamage(bonusEffect)?:
			guard let moveTarget = target else { return }
			bonusEffect(moveTarget, lastDamage)

		case let .multiTurnMove(condition, addAttack)?:
			guard let moveTarget = target else { return }
			if !condition(self) {
				let textToAdd = addAttack(attack, moveTarget)
				view?.queue(action: .displayText(textToAdd))
			}

		case .none, .instanceOfMultiHit?:
			break
		}
	}

	private func run() {
		print("---")
		print("Turn \(turnCounter)")
		print("---")

		while resolveTurns {
			sortTurns()

			while !turns.isEmpty {
				view?.disableButtons()
				/* 	Lookahead to allow multi-hit moves to be added to the turns array without screwing up weather and terrain counters
				 Without this code, when multi-hit moves are used, run() breaks out, and is called again multiple times,
				 by resolveTurns's didSet which ends up decrementing the weather and terrain counters
				 */
				if
					let lookahead = turns.first,
					case let .attack(attack) = lookahead.action,
					case .multiHitMove? = attack.bonusEffect {
					multiHitMoveRunning = true
				}

				let turn = turns.removeFirst()

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
					for case let .preparingTo(attack) in attacker.volatileStatus {
						attacker.volatileStatus.remove(.preparingTo(attack))
					}

					print("\(playerOne.name)'s \(playerOne.activePokemon) - Lv. \(playerOne.activePokemon.level) has \(playerOne.activePokemon.currentHP)/\(playerOne.activePokemon.baseStats.hp) HP")
					print("\(playerTwo.name)'s \(playerTwo.activePokemon) - Lv. \(playerTwo.activePokemon.level) has \(playerTwo.activePokemon.currentHP)/\(playerTwo.activePokemon.baseStats.hp) HP")

					/// Attack
					/// Attacker, Defender: Pokemon

					func confusionCheck() -> Bool {
						for case let .confused(number) in attacker.volatileStatus {
							view?.queue(action: .displayText("\(attacker.nickname) is confused!"))

							if number == 0 {
								attacker.volatileStatus.remove(.confused(0))
								view?.queue(action: .displayText("\(attacker.nickname) snapped out of its confusion!"))
								return true
							} else {
								let diceRoll = Random.shared.d3Roll()

								if diceRoll == 1 {
									view?.queue(action: .displayText("\(attacker.nickname) hurt itself in its confusion!"))
									print("\(attacker.nickname) hurt itself in its confusion!")

									let (baseDamage, _) = calculateDamage(attacker: attacker, defender: attacker, attack: Attack(name: "Confused", power: 40, basePP: 1, maxPP: 1, priority: 0, type: .typeless, category: .physical))
									view?.queue(action: .confusedAttack(attacker))
									attacker.damage(baseDamage)
									return false
								} else {
									return true
								}
							}
						}

						return true
					}

					func paralysisCheck() -> Bool {
						// Early return if Pokémon status isn't paralysed
						guard attacker.status == .paralysed else { return true }

						let diceRoll = Random.shared.d3Roll()
						if diceRoll == 1 {
							view?.queue(action: .displayText("\(attacker) is paralysed"))
							return false
						} else {
							return true
						}
					}

					func sleepCheck() -> Bool {
						// Early return if Pokémon's status isn't asleep
						guard case let .asleep(counter) = attacker.status else { return true }

						if counter == 0 {
							attacker.status = .healthy
							view?.queue(action: .displayText("\(attacker) woke up!"))
							return true
						} else {
							return false
						}
					}

					func protectedCheck() -> Bool {
						if defender.volatileStatus.contains(.protected), !attack.breaksProtect {
							view?.queue(action: .displayText("\(attacker.nickname) used \(attack.name)"))
							view?.queue(action: .displayText("\(defender.nickname) is protected!"))
							return false
						} else {
							return true
						}
					}

					func hitCheck() -> Bool {
						if let accuracy = attack.accuracy {
							let hit = Random.shared.shouldHit(chance: accuracy)

							if !hit {
								view?.queue(action: .displayText("\(attacker.nickname) used \(attack.name)"))
								view?.queue(action: .displayText("But it missed!"))
							}
							return hit
						} else {
							return true
						}
					}

					let shouldAttack = [
						confusionCheck(),
						sleepCheck(),
						paralysisCheck(),
						protectedCheck(),
						hitCheck(),
					].allSatisfy { $0 }

					if shouldAttack {
						successfulDamage(attacker: attacker, defender: defender, attack: attack)
					} else {
						break
					}

					switch attack.effectTarget {
					case .attacker?:
						runBonusEffect(attack: attack, target: attacker, player: turn.player)
						print("\(attacker)'s stats are now: \(attacker.baseStats)")
					case .defender?:
						runBonusEffect(attack: attack, target: defender, player: turn.player)
					default:
						runBonusEffect(attack: attack, player: turn.player)
					}

				case let .switchTo(pokemon), let .forceSwitch(pokemon):
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

				if case let .asleep(counter) = player.activePokemon.status {
					player.activePokemon.status = .asleep(counter - 1)
				}

				player.activePokemon.volatileStatus.remove(.protected)
				player.activePokemon.volatileStatus.remove(.flinch)

				player.activePokemon.volatileStatus = Set(player.activePokemon.volatileStatus.map { $0.turn() })

				if player.activePokemon.status == .fainted {
					view?.queue(action: .fainted(player.activePokemon))

					if !player.allFainted {
						state = .awaitingSwitch
					}

					print("Player whose Pokémon has fainted is: \(player.name)")

					if player.playerId == playerOne.playerId {
						activePlayer = playerOne
					} else {
						activePlayer = playerTwo
					}
				}
			}

			print("\(playerOne.name)'s \(playerOne.activePokemon) has \(playerOne.activePokemon.currentHP)/\(playerOne.activePokemon.baseStats.hp) HP remaining")
			print("\(playerTwo.name)'s \(playerTwo.activePokemon) has \(playerTwo.activePokemon.currentHP)/\(playerTwo.activePokemon.baseStats.hp) HP remaining")

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
		self.activePlayer = playerOne
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

		var weatherModifier: Double = 1

		if attack.type == .fire {
			weatherModifier = weather.fireModifier
		} else if attack.type == .water {
			weatherModifier = weather.waterModifier
		}

		var modifiedDamage = floor(innerBrackets * weatherModifier)
		modifiedDamage = floor(modifiedDamage * rng)
		modifiedDamage = floor(modifiedDamage * stab)
		modifiedDamage = floor(modifiedDamage * effectivenessMultiplier)

		let damage = Int(modifiedDamage)

		print("Final damage = \(damage)")

		print("---")

		return (damage, effectiveness)
	}

	public func addTurn(_ turn: Turn) {
		if turn.player.playerId == playerOne.playerId {
			activePlayer = playerTwo
		} else {
			activePlayer = playerOne
		}

		if !turns.isEmpty {
			switch turn.action {
			case .attack, .switchTo:
				removeTurns(belongingTo: turn.player)
				turns.append(turn)
			default:
				turns.append(turn)
			}
		} else {
			turns.append(turn)
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
		switchingPokemon.volatileStatus.removeAll()

		switchingPlayer.switchPokemon(pokemon: pokemon)

		view?.queue(action: .switchTo(Pokemon(pokemon: pokemon), for: player))
		state = .running
	}

	private func removeTurns(belongingTo player: Player) {
		turns = turns.filter { turn in
			switch turn.action {
			case .attack, .switchTo:
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

	/// Enum representing possible battle states
	public enum BattleState: String, Codable {
		/// State for when a Pokémon battle is running normally
		case running

		/// State for when a Pokémon battle has been completed
		case completed

		/// State for when the Battle Engine is waiting for a switch-in Pokémon from a player
		case awaitingSwitch
	}

	// MARK: - GameplayKit Methods

	public var players: [GKGameModelPlayer]? {
		[playerOne, playerTwo]
	}

	public var activePlayer: GKGameModelPlayer?

	public func setGameModel(_ gameModel: GKGameModel) {
		guard let model = gameModel as? BattleEngine else { fatalError() }

		self.state = model.state
		if let winner = model.winner {
			self.winner = Player(copying: winner)
		}

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

		guard let player = player as? Player else {
			return .min
		}

		let opponent: Player
		if player.playerId == playerOne.playerId {
			opponent = playerTwo
		} else {
			opponent = playerOne
		}

		guard player.playerId == playerOne.playerId || player.playerId == playerTwo.playerId else { return .min }

		func scoreValue(for number: Double) -> Int {
			switch number {
			case 0.9 ..< 1: return 10
			case 0.8 ..< 0.9: return 20
			case 0.7 ..< 0.8: return 30
			case 0.6 ..< 0.7: return 40
			case 0.5 ..< 0.6: return 50
			case 0.4 ..< 0.5: return 60
			case 0.3 ..< 0.4: return 70
			case 0.2 ..< 0.3: return 80
			case 0.1 ..< 0.2: return 90
			case 0: return 100
			default: return -10
			}
		}

		score += scoreValue(for: Double(opponent.activePokemon.currentHP) / Double(opponent.activePokemon.baseStats.hp))

		score -= scoreValue(for: Double(player.activePokemon.currentHP) / Double(player.activePokemon.baseStats.hp))

		if opponent.activePokemon.status != .healthy {
			score += 30
		}

		if !player.activePokemon.volatileStatus.isEmpty {
			for status in player.activePokemon.volatileStatus {
				switch status {
				case let .confused(counter):
					if counter > 0 {
						score -= 20
					}
				case .protected:
					score += 40
				case .flinch:
					score -= 30
				case .mustRecharge:
					score -= 20
				case .preparingTo:
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
						case let .preparingTo(attack):
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
				break
			case .awaitingSwitch:
				if player.activePokemon.status == .fainted {
					if !player.allFainted {
						for pokemon in player.team where pokemon.status != .fainted {
							possibleTurns?.append(Turn(player: player, action: .forceSwitch(pokemon)))
						}
					}
				}
			}
		}

		print("Possible turns for state = \(possibleTurns ?? []))")

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
		let copy = type(of: self).init(playerOne: Player(copying: playerOne), playerTwo: Player(copying: playerTwo))

		copy.setGameModel(self)

		return copy
	}

	public static func == (lhs: BattleEngine, rhs: BattleEngine) -> Bool {
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

	public static func != (lhs: BattleEngine, rhs: BattleEngine) -> Bool {
		!(lhs == rhs)
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
