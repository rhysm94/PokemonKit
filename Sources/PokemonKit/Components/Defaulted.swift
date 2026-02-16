//
//  Defaulted.swift
//  PokemonKit
//
//  Created by Rhys Morgan on 17/05/2020.
//  Copyright © 2020 Rhys Morgan. All rights reserved.
//

@propertyWrapper
public struct Defaulted<T> {
	let defaultValue: T

	private	var value: T?

	init(defaultValue: T, value: T?) {
		self.defaultValue = defaultValue
		self.value = value
	}

	public var wrappedValue: T {
		get { value ?? defaultValue }
		set { value = newValue }
	}
}

extension Defaulted: Codable where T: Codable {}
