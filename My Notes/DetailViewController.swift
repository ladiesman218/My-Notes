//
//  DetailViewController.swift
//  My Notes
//
//  Created by Lei Gao on 2022/M/1.
//

import UIKit

class DetailViewController: UIViewController {

	var fileURL: URL!
	
	@IBOutlet var textView: UITextView!
	
	override func viewDidLoad() {
        super.viewDidLoad()
		guard let string = try? String(contentsOf: fileURL) else {
			fatalError("Can't read content of the given url")
		}
		textView.text = string
		
		let notificationCenter = NotificationCenter.default
		notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardDidHideNotification, object: nil)
		notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardDidChangeFrameNotification, object: nil)
    }

	override func viewWillDisappear(_ animated: Bool) {
		let content = textView.text ?? ""
		guard content != "" else {
			try! FileManager.default.removeItem(at: fileURL)
			return
		}
		try! content.write(toFile: fileURL.path, atomically: true, encoding: .utf8)
	}

	@objc func adjustForKeyboard(notification: Notification) {
		guard let userInfo = notification.userInfo else {
			return
		}
		
		let keyboardScreenEndFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
		
		let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
		
		if notification.name == UIResponder.keyboardDidHideNotification {
			textView.contentInset = UIEdgeInsets.zero
		} else {
			textView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
		}
		textView.scrollIndicatorInsets = textView.contentInset
		let selectedRange = textView.selectedRange
		textView.scrollRangeToVisible(selectedRange)
		
	}
}
