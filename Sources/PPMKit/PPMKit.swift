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
		case invalidRowOrColumn
	}
}
