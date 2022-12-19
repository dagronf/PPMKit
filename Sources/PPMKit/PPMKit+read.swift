//
//  PPMKit+read.swift
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

//import CoreGraphics
import Foundation

public extension PPM {
	/// Load a CGImage from a PPM Data. Handles both P3 and P6 formats
	/// - Parameter fileURL: The file containing the PPM data
	/// - Returns: PPM data
	@inlinable static func readFileURL(_ fileURL: URL) throws -> ImageData {
		let data = try Data(contentsOf: fileURL)
		return try Self.readData(data)
	}

	/// Load a CGImage from PPM data. Handles both P3 and P6 formats
	/// - Parameter data: The data containing the PPM data
	/// - Returns: raw
	static func readData(_ data: Data) throws -> ImageData {
		var width = -1
		var height = -1
		var levels = -1
		var rawData: [Int] = []

		var inComment = false
		var inToken = false

		var index = 0

		var format: Format = .P3

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
			let current = data[index]

			if currentState == .rawContent && format == .P6 {
				rawData.append(Int(current))
			}
			else if inComment {
				// Comment runs to the end of the line
				if current ==  0x0A {
					inComment = false
				}
			}
			else if current == 0x23 { //}"#" {
				// Read to the end of the line
				inComment = true
			}
			else if current == 0x0A /*"\n"*/ || current == 0x20 /*" "*/ {
				if inComment {
					inComment = false
				}
				else if inToken {
					inToken = false

					switch currentState {
					case .header:
						switch currentToken {
						case "P3": format = .P3
						case "P6": format = .P6
						default:
							throw ErrorType.invalidPPMHeaderType
						}
						currentState = .width
					case .width:
						guard let w = Int(currentToken) else {
							throw ErrorType.invalidWidth
						}
						width = w
						currentState = .height
					case .height:
						guard let h = Int(currentToken) else {
							throw ErrorType.invalidHeight
						}
						height = h
						currentState = .levels
					case .levels:
						guard let l = Int(currentToken) else {
							throw ErrorType.invalidLevels
						}
						levels = l
						if format == .P3 {
							currentState = .content
						}
						else {
							currentState = .rawContent
						}
					case .content:
						assert(format == .P3)
						guard let v = Int(currentToken) else {
							throw ErrorType.invalidImageContent
						}
						rawData.append(v)
					case .rawContent:
						fatalError()
					}

					currentToken = ""
				}
			}
			else {
				// If we got here, its a token
				inToken = true
				var c = current
				guard let charS = String(data: Data(bytes: &c, count: 1), encoding: .ascii) else {
					throw ErrorType.invalidData
				}
				currentToken += charS
			}

			index += 1
		}

		guard width * height * 3 == rawData.count else {
			throw ErrorType.mismatchWidthHeightAndContent
		}

		let ll = Double(levels)
		
		// Convert to 0->255 levels
		let mapped = Data(rawData.map { UInt8((Double($0) / ll) * 255) })
		return ImageData(data: mapped, width: width, height: height)
	}
}
