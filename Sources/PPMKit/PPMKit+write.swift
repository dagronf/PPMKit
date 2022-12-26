//
//  PPMKit+write.swift
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
	/// Write a RGBA byte array to PPM Data
	/// - Parameters:
	///   - cgImage: The image to convert
	///   - format: The PPM format
	/// - Returns: The raw PPM Data
	static func writeData(_ data: ImageData, format: Format) throws -> Data {
		var str = format == .P3 ? "P3\n" : "P6\n"
		str += "\(data.width) \(data.height) 255\n"

		if format == .P3 {
			for rgb in data.data.enumerated() {
				str += "\(rgb.1.r) \(rgb.1.g) \(rgb.1.b)\n"
			}

			guard let data = str.data(using: .ascii) else {
				throw ErrorType.unableToCreateString
			}
			return data
		}
		else {
			guard let d = str.data(using: .ascii) else {
				throw ErrorType.unableToCreateString
			}
			var result = Data(d)
			for datum in data.data {
				result.append(datum.r)
				result.append(datum.g)
				result.append(datum.b)
			}
			return result
		}
	}
}
