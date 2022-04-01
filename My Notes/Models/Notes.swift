//
//  Notes.swift
//  My Notes
//
//  Created by Lei Gao on 2022/M/2.
//

import UIKit


struct Note:  Codable {
	var content: String {
		didSet {
			self.lastModifyTime = Date()
		}
	}
	var fileName: String? // For a unsaved note, name is nil
	var lastModifyTime: Date?
	// Can't save and use file url directly, since that contains a device UUID which may change during each run in simulator. Eg, a file path may be /Users/x/device/123/fileName this time, and /User/x/device/456/fileName next time.
	var fileURL: URL? {
		if let fileName = fileName {
			return path.appendingPathComponent(fileName)
		}
		return nil
	}
	
	init(content: String, fileName: String? = nil) {
		self.content = content
		self.fileName = fileName
	}
	
	mutating func writeToDisk() {
		// Update existing file
		if self.fileName != nil {
			let data = try! JSONEncoder().encode(self)
			try! data.write(to: fileURL!)
			return
		} else {
			// Set a file name then save an unsaved file
			self.fileName = UUID().uuidString
			let data = try! JSONEncoder().encode(self)
			try! data.write(to: fileURL!)
		}
	}
	
	func removeFromDisk() {
		try! FileManager.default.removeItem(at: fileURL!)
	}
}
