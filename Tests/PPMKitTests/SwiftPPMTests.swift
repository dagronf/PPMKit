import XCTest
@testable import PPMKit

let TempFileContainer = TemporaryFilesContainer(folderName: "PPM_Tests")

let ppm1URL = try! XCTUnwrap(Bundle.module.url(forResource: "P3_4x4_L16", withExtension: "ppm"))
let ppm2URL = try! XCTUnwrap(Bundle.module.url(forResource: "P3_3x2_L255", withExtension: "ppm"))
let ppm3URL = try! XCTUnwrap(Bundle.module.url(forResource: "P6_4x4_L255", withExtension: "ppm"))
let ppm4URL = try! XCTUnwrap(Bundle.module.url(forResource: "sample_640×426", withExtension: "ppm"))
let ppm5URL = try! XCTUnwrap(Bundle.module.url(forResource: "P6_320x200_L255", withExtension: "ppm"))

#if !os(Linux)

final class SwiftPPMTests: XCTestCase {
	func testSimpleP3_4x4() throws {
		let im = try XCTUnwrap(PPM.readImage(fileURL: ppm1URL))
		XCTAssertEqual(4, im.width)
		XCTAssertEqual(4, im.height)

		let data = try XCTUnwrap(PPM.writeImage(im, format: .P3))
		let imd2 = try XCTUnwrap(PPM.readImage(data: data))
		XCTAssertEqual(4, imd2.width)
		XCTAssertEqual(4, imd2.height)
	}

	func testSimpleP3_3x2() throws {
		let im = try XCTUnwrap(PPM.readImage(fileURL: ppm2URL))
		XCTAssertEqual(3, im.width)
		XCTAssertEqual(2, im.height)

		// Store as PPM data
		let data = try XCTUnwrap(PPM.writeImage(im, format: .P3))

		// Load from saved data
		let imd2 = try XCTUnwrap(PPM.readImage(data: data))

		XCTAssertEqual(3, imd2.width)
		XCTAssertEqual(2, imd2.height)
	}

	func testSimpleP6Example() throws {
		let im = try XCTUnwrap(PPM.readImage(fileURL: ppm3URL))
		XCTAssertEqual(4, im.width)
		XCTAssertEqual(4, im.height)

		let sdata = try XCTUnwrap(PPM.writeImage(im, format: .P6))
		let imd2 = try XCTUnwrap(PPM.readImage(data: sdata))

		XCTAssertEqual(4, imd2.width)
		XCTAssertEqual(4, imd2.height)
	}

	func testSimpleP6Example2() throws {
		// 640 426
		let im = try XCTUnwrap(PPM.readImage(fileURL: ppm4URL))
		XCTAssertEqual(640, im.width)
		XCTAssertEqual(426, im.height)

		let sdata = try XCTUnwrap(PPM.writeImage(im, format: .P6))
		let imd2 = try XCTUnwrap(PPM.readImage(data: sdata))

		XCTAssertEqual(640, imd2.width)
		XCTAssertEqual(426, imd2.height)
	}

	func testSimpleP6Example3() throws {
		let im = try XCTUnwrap(PPM.readImage(fileURL: ppm5URL))
		XCTAssertEqual(320, im.width)
		XCTAssertEqual(200, im.height)
		
		let sdata = try XCTUnwrap(PPM.writeImage(im, format: .P6))
		let imd2 = try XCTUnwrap(PPM.readImage(data: sdata))
		
		XCTAssertEqual(320, imd2.width)
		XCTAssertEqual(200, imd2.height)
		
		// Convert to p3
		let sdata_p3 = try XCTUnwrap(PPM.writeImage(im, format: .P3))
		// Check that we can re-load
		let imd_p3 = try XCTUnwrap(PPM.readImage(data: sdata_p3))
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
		let p3DataURL = TempFileContainer.temporaryFileWithName("gps-image-p3.ppm")
		try p3Data.write(to: p3DataURL)

		let p6Data = try PPM.writeImage(cg1, format: .P6)
		let p6DataURL = TempFileContainer.temporaryFileWithName("gps-image-p6.ppm")
		try p6Data.write(to: p6DataURL)

		let reloaded = try PPM.readImage(data: p3Data)
		XCTAssertEqual(origW, reloaded.width)
		XCTAssertEqual(origH, reloaded.height)

		let reloaded2 = try PPM.readImage(data: p6Data)
		XCTAssertEqual(origW, reloaded2.width)
		XCTAssertEqual(origH, reloaded2.height)
	}
	#endif
}

#endif

final class SwiftPPMDataOnlyTests: XCTestCase {
	func testCommentFail() throws {
		let ppm6URL = try! XCTUnwrap(Bundle.module.url(forResource: "P3_3x2_L255_comment_fail", withExtension: "ppm"))

		let im = try XCTUnwrap(PPM.ImageData.read(fileURL: ppm6URL))
		XCTAssertEqual(3, im.width)
		XCTAssertEqual(2, im.height)
		XCTAssertEqual(3 * 2, im.data.count)
	}

	func testInvalidContent() throws {
		let ppm6URL = try! XCTUnwrap(Bundle.module.url(forResource: "badly_formatted", withExtension: "ppm"))
		XCTAssertThrowsError(try PPM.read(fileURL: ppm6URL))
	}

	func testWriteData_p3() throws {
		let imageData = try PPM.ImageData.read(fileURL: ppm3URL)
		let ppmData = try imageData.ppmData(format: .P3)
		let ppmDataURL = TempFileContainer.temporaryFileWithName("writtenrawdata_p3.ppm")
		try ppmData.write(to: ppmDataURL)

		let d1 = try PPM.ImageData.read(fileURL: ppmDataURL)
		XCTAssertEqual(d1, imageData)
	}

	func testWriteData_p6() throws {
		let imageData = try PPM.ImageData.read(fileURL: ppm3URL)
		let ppmData = try imageData.ppmData(format: .P6)
		let ppmDataURL = TempFileContainer.temporaryFileWithName("writtenrawdata_p6.ppm")
		try ppmData.write(to: ppmDataURL)

		let d1 = try PPM.ImageData.read(fileURL: ppmDataURL)
		XCTAssertEqual(d1, imageData)
	}
}
