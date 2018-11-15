//
//  Time.swift
//  PokemonKit
//
//  Created by Rhys Morgan on 10/11/2018.
//  Copyright © 2018 Rhys Morgan. All rights reserved.
//

/// Times of the day in-game
public enum Time: String, Codable, Hashable {
	
	/// 06:00 - 16:59
	case day
	
	/// 17:00 - 17:59
	case twilight
	
	/// 18:00 - 05:59
	case night
}
