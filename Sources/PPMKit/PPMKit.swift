//
//  PPMKit.swift
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

// http://www.paulbourke.net/dataformats/ppm/
// http://people.uncw.edu/tompkinsj/112/texnh/assignments/imageFormat.html

import Foundation

public final class PPM {
	private init() {}

	/// Writing formats
	public enum Format {
		case P3
		case P6
	}

	/// Errors throws
	public enum ErrorType: Error {
		case invalidPPMHeaderType(actualBOM: String)
		case invalidData
		case invalidWidth(actualWidthString: String)
		case invalidHeight(actualHeightString: String)
		case invalidLevels(actualLevelsString: String)
		case cannotConvertImageToByteArray
		case invalidImageContent(actualValueString: String)
		case mismatchWidthHeightAndContent(width: Int, height: Int, actualByteCount: Int)
		case invalidPPMData
		case cannotCreateImage
		case unableToCreateString
		case unexpectedRawContentCode
		case invalidDimensionsForData
	}

	/// An RGB pixel representation
	public struct RGB {
		/// red component
		public let r: UInt8
		/// green component
		public let g: UInt8
		/// blue component
		public let b: UInt8
	}

	/// Raw image data
	public struct ImageData {
		/// Raw RGB byte array
		public let data: [PPM.RGB]
		/// Image width (in pixels)
		public let width: Int
		/// Image height (in pixels)
		public let height: Int

		/// Return the pixel data as a raw RGB byte array
		public func rawBytes() -> Data {
			Data(self.data.flatMap { [$0.r, $0.g, $0.b] })
		}

		init(rgbData: [PPM.RGB], width: Int, height: Int) throws {
			if rgbData.count != (width * height) {
				throw ErrorType.invalidDimensionsForData
			}
			self.data = rgbData
			self.width = width
			self.height = height
		}

		/// Create imagedata from a raw RGB array
		init(rawBytes: Data, width: Int, height: Int) throws {
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
