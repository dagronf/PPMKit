//
//  PPMKit+platform.swift
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

#if os(macOS)

import AppKit
public extension NSImage {
	/// Create an NSImage from a PPM.Image
	convenience init?(ppmImage: PPM.Image) {
		guard let cgImage = try? ppmImage.cgImage() else { return nil }
		self.init(
			cgImage: cgImage,
			size: NSSize(width: ppmImage.width, height: ppmImage.height)
		)
	}

	/// Load an NSImage from PPM data
	convenience init?(ppmData: Data) {
		guard let cgImage = try? PPM.readImage(data: ppmData) else { return nil }
		self.init(
			cgImage: cgImage,
			size: CGSize(width: cgImage.width, height: cgImage.height)
		)
	}

	/// Returns PPM data in the specified format for the image
	func ppmData(format: PPM.Format) throws -> Data {
		guard
			let cgImage = self.cgImage(forProposedRect: nil, context: nil, hints: nil)
		else {
			throw PPM.ErrorType.cannotCreateImage
		}
		return try PPM.writeImage(cgImage, format: format)
	}
}

#elseif os(iOS) || os(tvOS) || os(watchOS)

import UIKit
public extension UIImage {

	/// Create a UIImage from a PPM.Image
	convenience init?(ppmImage: PPM.Image) {
		guard let cgImage = try? ppmImage.cgImage() else { return nil }
		self.init(cgImage: cgImage)
	}

	/// Create a UIImage from raw image data
	convenience init?(ppmData: Data) {
		guard let cgImage = try? PPM.readImage(data: ppmData) else {
			return nil
		}
		self.init(cgImage: cgImage)
	}

	/// Returns PPM data in the specified format for this image
	func ppmData(format: PPM.Format) throws -> Data {
		guard let cgImage = self.cgImage else {
			throw PPM.ErrorType.cannotCreateImage
		}
		return try PPM.writeImage(cgImage, format: format)
	}
}

#endif
