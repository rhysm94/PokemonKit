//
//  Random.swift
//  PokemonKit
//
//  Created by Rhys Morgan on 22/02/2018.
//  Copyright © 2018 Rhys Morgan. All rights reserved.
//

import Foundation
import GameplayKit

public class Random {
	public static var shared = Random(seed: UUID().uuidString)

	let randomSource: GKRandomSource
	let random: GKRandomDistribution

	public init(seed: String) {
		print("init(seed:) for Random run with seed: \(seed)")
		let dataSeed = Data(seed.utf8)
		self.randomSource = GKARC4RandomSource(seed: dataSeed)
		self.random = GKRandomDistribution(randomSource: randomSource, lowestValue: 0, highestValue: 15)
	}

	private init(source: GKRandomSource) {
		self.randomSource = source
		self.random = GKRandomDistribution(randomSource: randomSource, lowestValue: 0, highestValue: 15)
	}

	func battleRNG() -> Double {
		Double(100 - random.nextInt())
	}

	func confusion() -> Int {
		random.nextInt(upperBound: 4) + 1
	}

	func d10Roll() -> Int {
		random.nextInt(upperBound: 10) + 1
	}

	func d6Roll() -> Int {
		random.nextInt(upperBound: 6) + 1
	}

	func d5Roll() -> Int {
		random.nextInt(upperBound: 5) + 1
	}

	func d3Roll() -> Int {
		random.nextInt(upperBound: 3) + 1
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
	}

	func copy() -> Random {
		guard let copyRandomSource = randomSource.copy() as? GKRandomSource else { fatalError() }

		return Random(source: copyRandomSource)
	}
}
