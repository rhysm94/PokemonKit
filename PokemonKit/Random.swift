//
//  SharedRandom.swift
//  PokemonBattleEngineTest
//
//  Created by Rhys Morgan on 22/02/2018.
//  Copyright © 2018 Rhys Morgan. All rights reserved.
//

import Foundation
import GameplayKit

class Random {
	static var shared: Random!
	var randomSource: GKARC4RandomSource!
	let random: GKRandomDistribution
	
	init(seed: String) {
		print("init(seed:) for Random run with seed: \(seed)")
		let dataSeed = seed.data(using: .utf8)!
		randomSource = GKARC4RandomSource(seed: dataSeed)
		self.random = GKRandomDistribution(randomSource: randomSource, lowestValue: 1, highestValue: 16)
	}
	
	func battleRNG() -> Int {
		return 101 - random.nextInt()
	}
	
	func confusion() -> Int {
		return random.nextInt(upperBound: 4)
	}
	
	func sleep() -> Int {
		return random.nextInt(upperBound: 5)
	}
	
	func d10Roll() -> Int {
		return random.nextInt(upperBound: 10)
	}
	
	func d6Roll() -> Int {
		return random.nextInt(upperBound: 6)
	}
	
	func d5Roll() -> Int {
		return random.nextInt(upperBound: 5)
	}
	
	func between(minimum: Int, maximum: Int) -> Int {
		let number = random.nextInt(upperBound: maximum)
		return minimum > number ? minimum : number
	}
}
