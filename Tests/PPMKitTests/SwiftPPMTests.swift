import XCTest
@testable import PPMKit

let ppm1URL = try! XCTUnwrap(Bundle.module.url(forResource: "P3_4x4_L16", withExtension: "ppm"))
let ppm2URL = try! XCTUnwrap(Bundle.module.url(forResource: "P3_3x2_L255", withExtension: "ppm"))
let ppm3URL = try! XCTUnwrap(Bundle.module.url(forResource: "P6_4x4_L255", withExtension: "ppm"))
let ppm4URL = try! XCTUnwrap(Bundle.module.url(forResource: "sample_640×426", withExtension: "ppm"))
let ppm5URL = try! XCTUnwrap(Bundle.module.url(forResource: "P6_320x200_L255", withExtension: "ppm"))

#if !os(Linux)

final class SwiftPPMTests: XCTestCase {
	func testSimpleP3_4x4() throws {
		// This is an example of a functional test case.
		// Use XCTAssert and related functions to verify your tests produce the correct
		// results.

		let im = try XCTUnwrap(PPM.readImage(ppm1URL))
		XCTAssertEqual(4, im.width)
		XCTAssertEqual(4, im.height)

		let data = try XCTUnwrap(PPM.writeImage(im, format: .P3))
		let imd2 = try XCTUnwrap(PPM.readImage(data))
		XCTAssertEqual(4, imd2.width)
		XCTAssertEqual(4, imd2.height)
	}

	func testSimpleP3_3x2() throws {
		let im = try XCTUnwrap(PPM.readImage(ppm2URL))
		XCTAssertEqual(3, im.width)
		XCTAssertEqual(2, im.height)

		// Store as PPM data
		let data = try XCTUnwrap(PPM.writeImage(im, format: .P3))

		// Load from saved data
		let imd2 = try XCTUnwrap(PPM.readImage(data))

		XCTAssertEqual(3, imd2.width)
		XCTAssertEqual(2, imd2.height)
	}

	func testSimpleP6Example() throws {
		let im = try XCTUnwrap(PPM.readImage(ppm3URL))
		XCTAssertEqual(4, im.width)
		XCTAssertEqual(4, im.height)

		let sdata = try XCTUnwrap(PPM.writeImage(im, format: .P6))
		let imd2 = try XCTUnwrap(PPM.readImage(sdata))

		XCTAssertEqual(4, imd2.width)
		XCTAssertEqual(4, imd2.height)
	}

	func testSimpleP6Example2() throws {
		// 640 426
		let im = try XCTUnwrap(PPM.readImage(ppm4URL))
		XCTAssertEqual(640, im.width)
		XCTAssertEqual(426, im.height)

		let sdata = try XCTUnwrap(PPM.writeImage(im, format: .P6))
		let imd2 = try XCTUnwrap(PPM.readImage(sdata))

		XCTAssertEqual(640, imd2.width)
		XCTAssertEqual(426, imd2.height)
	}

	func testSimpleP6Example3() throws {
		let im = try XCTUnwrap(PPM.readImage(ppm5URL))
		XCTAssertEqual(320, im.width)
		XCTAssertEqual(200, im.height)
		
		let sdata = try XCTUnwrap(PPM.writeImage(im, format: .P6))
		let imd2 = try XCTUnwrap(PPM.readImage(sdata))
		
		XCTAssertEqual(320, imd2.width)
		XCTAssertEqual(200, imd2.height)
		
		// Convert to p3
		let sdata_p3 = try XCTUnwrap(PPM.writeImage(im, format: .P3))
		// Check that we can re-load
		let imd_p3 = try XCTUnwrap(PPM.readImage(sdata_p3))
		XCTAssertEqual(320, imd_p3.width)
		XCTAssertEqual(200, imd_p3.height)
	}

	#if os(macOS)
	func testSimpleJPEG() throws {
		let jpegURL = try! XCTUnwrap(Bundle.module.url(forResource: "gps-image", withExtension: "jpg"))
		let image = NSImage(contentsOf: jpegURL)!
		let cg1 = image.cgImage(forProposedRect: nil, context: nil, hints: nil)!
		let origW = cg1.width
		let origH = cg1.height

		// Write to a PPM P3 file
		let p3Data = try PPM.writeImage(cg1, format: .P3)
		try p3Data.write(to: URL(string: "file:///tmp/gps-image-p3.ppm")!)

		let p6Data = try PPM.writeImage(cg1, format: .P6)
		try p6Data.write(to: URL(string: "file:///tmp/gps-image-p6.ppm")!)

		let reloaded = try PPM.readImage(p3Data)
		XCTAssertEqual(origW, reloaded.width)
		XCTAssertEqual(origH, reloaded.height)

		let reloaded2 = try PPM.readImage(p6Data)
		XCTAssertEqual(origW, reloaded2.width)
		XCTAssertEqual(origH, reloaded2.height)
	}
	#endif
}

#endif

final class SwiftPPMDataOnlyTests: XCTestCase {
	func testCommentFail() throws {
		let ppm6URL = try! XCTUnwrap(Bundle.module.url(forResource: "P3_3x2_L255_comment_fail", withExtension: "ppm"))

		let im = try XCTUnwrap(PPM.readFileURL(ppm6URL))
		XCTAssertEqual(3, im.width)
		XCTAssertEqual(2, im.height)
		XCTAssertEqual(3 * 2 * 3, im.data.count)
	}

	func testInvalidContent() throws {
		let ppm6URL = try! XCTUnwrap(Bundle.module.url(forResource: "badly_formatted", withExtension: "ppm"))

		XCTAssertThrowsError(try PPM.readFileURL(ppm6URL))
	}
}
