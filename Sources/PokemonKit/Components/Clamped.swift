//
//  Clamped.swift
//  PokemonKit
//
//  Created by Rhys Morgan on 17/05/2020.
//  Copyright © 2020 Rhys Morgan. All rights reserved.
//

@propertyWrapper
public struct Clamped<Number> where Number: Numeric, Number: Comparable {
	let range: ClosedRange<Number>

	public init(wrappedValue value: Number, to range: ClosedRange<Number>) {
		self.range = range
		self.wrappedValue = value
	}

	private var value: Number = .zero

	public var wrappedValue: Number {
		get { value }
		set {
			value = newValue.clamped(to: range)
		}
	}
}

extension Clamped: Equatable where Number: Equatable {}
extension Clamped: Codable where Number: Codable {}

extension Comparable {
	public func clamped(to range: ClosedRange<Self>) -> Self {
		min(max(range.lowerBound, self), range.upperBound)
	}
}
