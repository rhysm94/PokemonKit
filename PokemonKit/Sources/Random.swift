//
//  Random.swift
//  PokemonBattleEngineTest
//
//  Created by Rhys Morgan on 22/02/2018.
//  Copyright © 2018 Rhys Morgan. All rights reserved.
//

import Foundation
import GameplayKit

public class Random {
	public static var shared: Random!
	var randomSource: GKRandomSource!
	let random: GKRandomDistribution
	
	public init(seed: String) {
		print("init(seed:) for Random run with seed: \(seed)")
		let dataSeed = seed.data(using: .utf8)!
		randomSource = GKARC4RandomSource(seed: dataSeed)
		self.random = GKRandomDistribution(randomSource: randomSource, lowestValue: 0, highestValue: 15)
	}
	
	private init(source: GKRandomSource) {
		self.randomSource = source
		self.random = GKRandomDistribution(randomSource: randomSource, lowestValue: 0, highestValue: 15)
	}
	
	func battleRNG() -> Double {
		return Double(100 - random.nextInt())
	}
	
	func confusion() -> Int {
		return random.nextInt(upperBound: 4) + 1
	}
	
	func d10Roll() -> Int {
		return random.nextInt(upperBound: 10) + 1
	}
	
	func d6Roll() -> Int {
		return random.nextInt(upperBound: 6) + 1
	}
	
	func d5Roll() -> Int {
		return random.nextInt(upperBound: 5) + 1
	}
	
	func d3Roll() -> Int {
		return random.nextInt(upperBound: 3) + 1
	}
	
	func between(minimum: Int, maximum: Int) -> Int {
		let upperBound = maximum + 1 - minimum
		var number = random.nextInt(upperBound: upperBound)
		number += minimum
		return number
	}
	
	func shouldHit(chance: Int) -> Bool {
		guard chance > 0 else { return false }
		guard chance < 100 else { return true }

		return random.nextUniform() <= (Float(chance) / 100.0)

//		var chances = [Bool]()
//		for _ in 1...chance {
//			chances.append(true)
//		}
//		for _ in 1...(100-chance) {
//			chances.append(false)
//		}
//
//		chances = randomSource.arrayByShufflingObjects(in: chances) as! [Bool]
//		return chances[0]
	}
	
	func copy() -> Random {
		guard let copyRandomSource = self.randomSource.copy() as? GKRandomSource else { fatalError() }
		
		return Random(source: copyRandomSource)
	}
}
