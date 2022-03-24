//
//  Notes.swift
//  My Notes
//
//  Created by Lei Gao on 2022/M/2.
//

import UIKit


class Note:  Codable {
	var content: String
	var fileName: String
	// Can't save and use file url directly, since that contains a device UUID which may change during each run in simulator. Eg, a file path may be /Users/x/device/123/fileName this time, and /User/x/device/456/fileName next time.
	var fileURL: URL {
		path.appendingPathComponent(fileName)
	}
	
	init(content: String, fileName: String) {
		self.content = content
		self.fileName = fileName
	}
	
	func writeToDisk() {
		let data = try! JSONEncoder().encode(self)
		try! data.write(to: fileURL)
	}
	
	func removeFromDisk() {
		try! FileManager.default.removeItem(at: fileURL)
	}
}
