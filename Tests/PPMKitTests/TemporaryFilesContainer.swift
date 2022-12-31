//
//  TemporaryFilesContainer.swift
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

class TemporaryFilesContainer {
	let tmpFolder: URL
	init(folderName: String) {

		let formatter = ISO8601DateFormatter()
		formatter.formatOptions = [.withDay, .withMonth, .withYear, .withTime, .withTimeZone]
		formatter.timeZone = TimeZone.current
		let u = FileManager.default
			.temporaryDirectory
			.appendingPathComponent(folderName)
			.appendingPathComponent(formatter.string(from: Date()))
		try! FileManager.default.createDirectory(at: u, withIntermediateDirectories: true)
		Swift.print("Temp files at: \(u)")
		self.tmpFolder = u
	}

	// Returns a file URL in the file container
	func temporaryFileWithName(_ name: String) -> URL {
		self.tmpFolder.appendingPathComponent(name)
	}
}
