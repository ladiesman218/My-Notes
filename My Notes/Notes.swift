//
//  Notes.swift
//  My Notes
//
//  Created by Lei Gao on 2022/M/2.
//

import UIKit

class Note:  Codable {
	var content: String
	var fileURL: URL

	init(content: String, fileURL: URL) {
		self.content = content
		self.fileURL = fileURL
	}
	
	func writeToDisk() {
		let data = try! JSONEncoder().encode(self)
		try! data.write(to: fileURL)
	}
}
