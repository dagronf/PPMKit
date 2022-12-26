//
//  ViewController.swift
//  PPM Viewer
//
//  Created by Darren Ford on 20/12/2022.
//

import Cocoa
import Quartz

class ViewController: NSViewController {

	@IBOutlet weak var imageView: IKImageView!

	var image: NSImage? = nil {
		didSet {
			self.imageView.setImage(image?.cgImage(forProposedRect: nil, context: nil, hints: nil), imageProperties: nil)
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
	}

	override var representedObject: Any? {
		didSet {
		// Update the view, if already loaded.
		}
	}


}

