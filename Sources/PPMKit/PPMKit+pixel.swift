//
//  PPMKit+pixel.swift
//
//  Copyright © 2022 Darren Ford. All rights reserved.
//
//  MIT License
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import Foundation

public extension PPM {
	/// An RGB pixel representation
	struct RGB: Equatable {
		/// Standard black
		public static let black = RGB(r: 0, g: 0, b: 0)
		/// Standard white
		public static let white = RGB(r: 255, g: 255, b: 255)

		/// Create a pixel with rgb values in 0 -> 255
		/// - Parameters:
		///   - r: red component
		///   - g: green component
		///   - b: blue component
		public init(r: UInt8, g: UInt8, b: UInt8) {
			self.r = r
			self.g = g
			self.b = b
		}

		/// Create a pixel with fractional rgb values clamped in 0 -> 1
		/// - Parameters:
		///   - r: red component
		///   - g: green component
		///   - b: blue component
		public init(rf: Double, gf: Double, bf: Double) {
			let r = min(1.0, max(0.0, rf))
			let g = min(1.0, max(0.0, gf))
			let b = min(1.0, max(0.0, bf))
			self.init(r: UInt8(r * 255), g: UInt8(g * 255), b: UInt8(b * 255))
		}

		/// red component
		public let r: UInt8
		/// green component
		public let g: UInt8
		/// blue component
		public let b: UInt8
	}
}
