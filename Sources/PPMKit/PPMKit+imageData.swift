//
//  PPMKit+imageData.swift
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
		/// red component
		public let r: UInt8
		/// green component
		public let g: UInt8
		/// blue component
		public let b: UInt8
	}
}

public extension PPM {
	/// Raw PPM image data
	struct ImageData: Equatable {
		/// Raw RGB byte array
		public let data: [PPM.RGB]
		/// Image width (in pixels)
		public let width: Int
		/// Image height (in pixels)
		public let height: Int

		/// Returns the pixel value at the specified row/column, or nil if the row or column is out of bounds
		@inlinable public func pixelAt(row: Int, column: Int) throws -> PPM.RGB {
			guard
				row >= 0, row < self.height,
				column >= 0, column < self.width
			else {
				throw PPM.ErrorType.invalidRowOrColumn
			}
			return self.data[(row * self.width) + column]
		}

		/// Return the pixel data as a raw RGB byte array
		public var rawBytes: Data {
			Data(self.data.flatMap { [$0.r, $0.g, $0.b] })
		}

		internal init(rgbData: [PPM.RGB], width: Int, height: Int) throws {
			if rgbData.count != (width * height) {
				throw PPM.ErrorType.invalidDimensionsForData
			}
			self.data = rgbData
			self.width = width
			self.height = height
		}

		/// Create imagedata from a raw RGB array
		internal init(rawBytes: Data, width: Int, height: Int) throws {
			if rawBytes.count != (width * height * 3) {
				throw ErrorType.invalidDimensionsForData
			}

			var result: [PPM.RGB] = []
			result.reserveCapacity(width * height)
			for step in stride(from: 0, to: rawBytes.count, by: 3) {
				result.append(RGB(r: rawBytes[step], g: rawBytes[step + 1], b: rawBytes[step + 2]))
			}

			self.width = width
			self.height = height
			self.data = result
		}
	}
}

// MARK: - Reading PPM data

public extension PPM {
	/// Load raw PPM Image data from a file URL. Handles both P3 and P6 formats
	/// - Parameter fileURL: The file containing the PPM data
	/// - Returns: PPM image data
	@inlinable static func read(fileURL: URL) throws -> PPM.ImageData {
		try PPM.ImageData.read(fileURL: fileURL)
	}

	/// Load raw PPM Image data from PPM data. Handles both P3 and P6 formats
	/// - Parameter data: The data containing the PPM data
	/// - Returns: PPM image data
	@inlinable static func read(data: Data) throws -> PPM.ImageData {
		try PPM.ImageData.read(data: data)
	}
}

public extension PPM.ImageData {
	/// Load raw PPM Image data from a file URL. Handles both P3 and P6 formats
	/// - Parameter fileURL: The file containing the PPM data
	/// - Returns: PPM image data
	@inlinable static func read(fileURL: URL) throws -> PPM.ImageData {
		assert(fileURL.isFileURL)
		let data = try Data(contentsOf: fileURL)
		return try Self.read(data: data)
	}

	/// Load raw PPM Image data from PPM data. Handles both P3 and P6 formats
	/// - Parameter data: The data containing the PPM data
	/// - Returns: PPM image data
	static func read(data: Data) throws -> PPM.ImageData {
		var width = -1
		var height = -1
		var levels = -1
		var rawData: [Int] = []

		var inComment = false
		var inToken = false

		var index = 0

		var format: PPM.Format = .P3

		enum State: Int {
			case header = 1
			case width = 2
			case height = 3
			case levels = 4
			case content = 5
			case rawContent = 6
		}

		var currentState: State = .header
		var currentToken = ""

		while index < data.count {
			let currentByte = data[index]

			if currentState == .rawContent && format == .P6 {
				// We're reading raw content - just loop to the end of the file
				rawData.append(Int(currentByte))
			}
			else if currentByte == 0x0D /* "\r" */ {
				// Ignore LR
			}
			else if inComment {
				// Comment runs to the end of the line
				if currentByte == 0x0A /* "\n" */ {
					inComment = false
				}
			}
			else if currentByte == 0x23 /* "#" */ {
				// Read to the end of the line
				inComment = true
			}
			else if currentByte == 0x0A /* "\n" */ || currentByte == 0x20 /* " " */ {
				// End of a token, or end of a comment
				if inComment {
					// End of a comment
					inComment = false
				}
				else if inToken {
					// The end of a token
					inToken = false

					switch currentState {
					case .header:
						switch currentToken {
						case "P3": format = .P3
						case "P6": format = .P6
						default:
							throw PPM.ErrorType.invalidPPMHeaderType(actualBOM: currentToken)
						}
						currentState = .width
					case .width:
						// Current token is the width
						guard let w = Int(currentToken) else {
							throw PPM.ErrorType.invalidWidth(actualWidthString: currentToken)
						}
						width = w
						currentState = .height
					case .height:
						// Current token is the height
						guard let h = Int(currentToken) else {
							throw PPM.ErrorType.invalidHeight(actualHeightString: currentToken)
						}
						height = h
						currentState = .levels
					case .levels:
						// Current token is the level
						guard let l = Int(currentToken) else {
							throw PPM.ErrorType.invalidLevels(actualLevelsString: currentToken)
						}
						levels = l
						if format == .P3 {
							currentState = .content
						}
						else {
							currentState = .rawContent
						}
					case .content:
						// P3 - text basic byte values
						assert(format == .P3)
						guard let v = Int(currentToken) else {
							throw PPM.ErrorType.invalidImageContent(actualValueString: currentToken)
						}
						rawData.append(v)
					case .rawContent:
						// Shouldn't get here - it should have been hijacked earlier
						assertionFailure("Shouldn't get here")
						throw PPM.ErrorType.unexpectedRawContentCode
					}

					currentToken = ""
				}
			}
			else {
				// If we got here, its a token
				inToken = true
				guard let charS = String(data: Data([currentByte]), encoding: .ascii) else {
					throw PPM.ErrorType.invalidData
				}
				currentToken += charS
			}

			index += 1
		}

		// Validate the content
		guard width * height * 3 == rawData.count else {
			throw PPM.ErrorType.mismatchWidthHeightAndContent(width: width, height: height, actualByteCount: rawData.count)
		}

		// We want to map the levels within the ppm file to 0 -> 255 range
		// The ppm file defines the maximum value for a pixel component, so
		// we need to map the values from (0 -> levels) to (0 -> 255)
		let levelsValue = Double(levels)

		// Convert to 0->255 levels
		let mappedData: [UInt8] = rawData.map {
			let mapped = (Double($0) / levelsValue) * 255
			let clamped = max(0, min(255, mapped))
			return UInt8(clamped)
		}
		return try PPM.ImageData(rawBytes: Data(mappedData), width: width, height: height)
	}
}

// MARK: - Writing PPM data

public extension PPM.ImageData {
	/// Write PPM image data to a file
	/// - Parameters:
	///   - data: The PPM image data
	///   - format: The PPM format to use when writing
	///   - fileURL: The file URL to write the PPM data
	@inlinable func write(format: PPM.Format, fileURL: URL) throws {
		assert(fileURL.isFileURL)
		try self.ppmData(format: format).write(to: fileURL)
	}

	/// Returns a PPM representation of the image data
	/// - Parameters:
	///   - format: The PPM format to use when writing
	/// - Returns: Raw PPM Data
	func ppmData(format: PPM.Format) throws -> Data {
		var str = format == .P3 ? "P3\n" : "P6\n"
		str += "\(self.width) \(self.height) 255\n"

		if format == .P3 {
			for rgb in self.data.enumerated() {
				str += "\(rgb.1.r) \(rgb.1.g) \(rgb.1.b)\n"
			}

			guard let data = str.data(using: .ascii) else {
				throw PPM.ErrorType.unableToCreateString
			}
			return data
		}
		else {
			guard let d = str.data(using: .ascii) else {
				throw PPM.ErrorType.unableToCreateString
			}
			var result = Data(d)
			for datum in self.data {
				result.append(datum.r)
				result.append(datum.g)
				result.append(datum.b)
			}
			return result
		}
	}
}
