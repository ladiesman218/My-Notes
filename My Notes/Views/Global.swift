//
//  Global.swift
//  My Notes
//
//  Created by Lei Gao on 2022/M/24.
//

import Foundation

let headerString = "备忘录"

let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!


extension Date {
	var localTime: String {
		get {
			let formatter = DateFormatter()
			formatter.locale = .current
			formatter.dateFormat = "yyyy/MM/dd HH:mm"

			return formatter.string(from: self)
		}
	}
	
	var localDateString: String {
		get {
			let formatter = DateFormatter()
			formatter.locale = .current
			formatter.dateFormat = "yyyy/MM/dd"
			return formatter.string(from: self)
		}
	}
	
	var localHourMinutesString: String {
		get {
			let formatter = DateFormatter()
			formatter.locale = .current
			formatter.dateFormat = "HH:mm"
			return formatter.string(from: self)

		}
	}
}


extension String {
	var firstLine: String {
		get {
			let endIndex = self.index(self.endIndex, offsetBy: -1)
			let enterIndex = self.firstIndex(of: "\n") ?? endIndex
			let string = String(self[self.startIndex...enterIndex])
			return (string == "\n") ? "" : string
		}
	}
}
