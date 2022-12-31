//
//  PPMKit+cgimage.swift
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

#if !os(Linux)

import CoreGraphics
import Foundation

// MARK: - Reading CGImages

public extension PPM {
	/// Read a CGImage from a PPM file. Handles both P3 and P6 formats
	/// - Parameter fileURL: The file to load
	/// - Returns: A CGImage representation of the PPM file
	@inlinable static func readImage(fileURL: URL) throws -> CGImage {
		let data = try Data(contentsOf: fileURL)
		return try Self.readImage(data: data)
	}

	/// Read a CGImage from PPM data. Handles both P3 and P6 formats
	/// - Parameter data: The data containing the PPM image
	/// - Returns: A CGImage representation of the PPM data
	@inlinable static func readImage(data: Data) throws -> CGImage {
		let ppmData = try PPM.ImageData.read(data: data)
		return try Self.readImage(imageData: ppmData)
	}

	/// Read a CGImage from PPM ImageData
	/// - Parameter imageData: Raw PPM image data
	/// - Returns: A CGImage representation
	static func readImage(imageData: PPM.ImageData) throws -> CGImage {
		// Convert the raw data to an image
		guard let provider = CGDataProvider(data: imageData.rawBytes as CFData) else {
			throw ErrorType.invalidPPMData
		}

		guard let cgImage = CGImage(
			width: imageData.width,
			height: imageData.height,
			bitsPerComponent: 8,
			bitsPerPixel: 24,
			bytesPerRow: imageData.width * 3,
			space: CGColorSpaceCreateDeviceRGB(),
			bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue),
			provider: provider,
			decode: nil,
			shouldInterpolate: true,
			intent: .defaultIntent
		)
		else {
			throw ErrorType.cannotCreateImage
		}

		return cgImage
	}
}

// MARK: - Writing CGImages

public extension PPM {
	/// Write a CGImage to a file
	/// - Parameters:
	///   - cgImage: The image to write
	///   - fileURL: The file to write to
	///   - format: The PPM file format
	@inlinable static func writeImage(_ image: CGImage, to fileURL: URL, format: Format) throws {
		let data = try Self.writeImage(image, format: format)
		try data.write(to: fileURL)
	}

	/// Write a CGImage to raw PPM data
	/// - Parameters:
	///   - cgImage: The image to write
	///   - format: The PPM format to use (P3, P6)
	/// - Returns: Raw PPM data
	static func writeImage(_ image: CGImage, format: Format) throws -> Data {
		// Get the raw RGBA data from the image
		let rawData = image.toByteArrayRGBA()
		guard rawData.count > 0 else {
			throw ErrorType.cannotConvertImageToByteArray
		}

		// Convert from RGBA bytes to [PPM.RGB]
		var rgbData: [PPM.RGB] = []
		rgbData.reserveCapacity(rawData.count)
		for offset in stride(from: 0, to: rawData.count, by: 4) {
			rgbData.append(PPM.RGB(r: rawData[offset], g: rawData[offset + 1], b: rawData[offset + 2]))
		}

		// Now write the data
		let ppmData = try ImageData(rgbData: rgbData, width: image.width, height: image.height)
		return try ppmData.ppmData(format: format)
	}
}

internal extension CGImage {
	/// Convert a CGImage to an RGBA array
	func toByteArrayRGBA() -> [UInt8] {
		var bytes = [UInt8](repeating: 0, count: width * height * 4)
		bytes.withUnsafeMutableBytes { ptr in
			if let context = CGContext(
				data: ptr.baseAddress,
				width: width,
				height: height,
				bitsPerComponent: 8,
				bytesPerRow: 4 * width,
				space: CGColorSpaceCreateDeviceRGB(),
				bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
			) {
				let rect = CGRect(x: 0, y: 0, width: width, height: height)
				context.draw(self, in: rect)
			}
		}
		return bytes
	}
}

#endif
