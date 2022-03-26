//
//  DetailViewController.swift
//  My Notes
//
//  Created by Lei Gao on 2022/M/1.
//

import UIKit

//protocol DetailVCDelegate {
//	func noteDidChange(note: Note)
//}

class DetailViewController: UIViewController {
	
	
	var note: Note!
	//	var delegate: DetailVCDelegate?
	
	@IBOutlet var textView: UITextView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		textView.text = note.content
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(remove))
		let shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))
		self.navigationController?.isToolbarHidden = false
		toolbarItems = [shareButton]
		
		let notificationCenter = NotificationCenter.default
		notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardDidHideNotification, object: nil)
		notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardDidChangeFrameNotification, object: nil)
		
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		note.content = textView.text!
		
		guard note.content != "" else {
			let fileName = note.fileURL.lastPathComponent
			
			let url = path.appendingPathComponent(fileName)
			try! FileManager.default.removeItem(at: url)
			return
		}
		note.writeToDisk()
		
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
	
	@objc func remove() {
		textView.text = ""
		self.navigationController?.popViewController(animated: true)
	}
	
	@objc func shareTapped() {
		guard let text = textView.text, text != "" else { return }
		
		
		let activityController = UIActivityViewController(activityItems: [text], applicationActivities: [
		])
		activityController.popoverPresentationController?.barButtonItem = navigationItem.leftBarButtonItem
		self.present(activityController, animated: true)
		
	}
}
