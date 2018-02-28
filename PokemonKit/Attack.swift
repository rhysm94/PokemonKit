//
//  Attack.swift
//  PokemonBattleEngineTest
//
//  Created by Rhys Morgan on 10/01/2018.
//  Copyright © 2018 Rhys Morgan. All rights reserved.
//

import Foundation

struct Attack: Codable {
	enum DamageCategory: String, Codable {
        case physical, special, status
    }
	
	enum EffectTarget: String, Codable {
        case attacker, defender
    }
	
	indirect enum BonusEffect {
        case singleTarget((Pokemon) -> Void)
        case setWeather(Weather)
        case setTerrain(Terrain)
		case multiHitMove(minHits: Int, maxHits: Int)
		case instanceOfMultiHit
    }
    
    let name: String
    let power: Int
    let basePP: Int
    let maxPP: Int
    let priority: Int
    let type: Type
    let breaksProtect: Bool
    let category: DamageCategory
    let effectTarget: EffectTarget?
    let bonusEffect: BonusEffect?
    
    init(name: String, power: Int, basePP: Int, maxPP: Int, priority: Int, type: Type, breaksProtect: Bool = false, category: DamageCategory, effectTarget: EffectTarget? = nil, bonusEffect: BonusEffect? = nil) {
        self.name = name
        self.power = power
        self.basePP = basePP
        self.maxPP = maxPP
        self.priority = priority
        self.type = type
        self.breaksProtect = breaksProtect
        self.category = category
        self.effectTarget = effectTarget
        self.bonusEffect = bonusEffect
    }
	
	enum CodingKeys: CodingKey {
		case name
		case power
		case basePP
		case maxPP
		case priority
		case type
		case breaksProtect
		case category
		case effectTarget
	}
	
	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(name, forKey: .name)
		try container.encode(power, forKey: .power)
		try container.encode(basePP, forKey: .basePP)
		try container.encode(maxPP, forKey: .maxPP)
		try container.encode(priority, forKey: .priority)
		try container.encode(type, forKey: .type)
		try container.encode(breaksProtect, forKey: .breaksProtect)
		try container.encode(category, forKey: .category)
		try container.encode(effectTarget, forKey: .effectTarget)
	}
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.name = try container.decode(String.self, forKey: .name)
		self.power = try container.decode(Int.self, forKey: .power)
		self.basePP = try container.decode(Int.self, forKey: .basePP)
		self.maxPP = try container.decode(Int.self, forKey: .maxPP)
		self.priority = try container.decode(Int.self, forKey: .priority)
		self.type = try container.decode(Type.self, forKey: .type)
		self.breaksProtect = try container.decode(Bool.self, forKey: .breaksProtect)
		self.category = try container.decode(DamageCategory.self, forKey: .category)
		self.effectTarget = try container.decode(EffectTarget?.self, forKey: .effectTarget)
		self.bonusEffect = Pokedex.default.attackBonuses[self.name]
	}
}

extension Attack: Equatable {
    static func ==(lhs: Attack, rhs: Attack) -> Bool {
        return lhs.name == rhs.name &&
            lhs.power == rhs.power &&
            lhs.basePP == rhs.basePP &&
            lhs.maxPP == rhs.maxPP &&
            lhs.priority == rhs.priority &&
            lhs.type == rhs.type &&
            lhs.category == rhs.category &&
            lhs.effectTarget == rhs.effectTarget
    }
}
