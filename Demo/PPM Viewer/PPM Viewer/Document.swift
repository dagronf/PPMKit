//
//  Document.swift
//  PPM Viewer
//
//  Created by Darren Ford on 20/12/2022.
//

import Cocoa
import PPMKit

class Document: NSDocument {

	var image: NSImage?

	override init() {
	    super.init()
		// Add your subclass-specific initialization here.
	}

	override class var autosavesInPlace: Bool {
		return false
	}

	override func makeWindowControllers() {
		// Returns the Storyboard that contains your Document window.
		let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
		let windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("Document Window Controller")) as! NSWindowController
		self.addWindowController(windowController)

		if let vc = windowController.contentViewController as? ViewController {
			vc.image = self.image
		}
	}

//	override func data(ofType typeName: String) throws -> Data {
//		// Insert code here to write your document to data of the specified type, throwing an error in case of failure.
//		// Alternatively, you could remove this method and override fileWrapper(ofType:), write(to:ofType:), or write(to:ofType:for:originalContentsURL:) instead.
//		throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
//	}

	override func read(from data: Data, ofType typeName: String) throws {
		// Insert code here to read your document from the given data of the specified type, throwing an error in case of failure.
		// Alternatively, you could remove this method and override read(from:ofType:) instead.
		// If you do, you should also override isEntireFileLoaded to return false if the contents are lazily loaded.
		let image = try PPM.readImage(data)
		self.image = NSImage(cgImage: image, size: .zero)
	}


}

