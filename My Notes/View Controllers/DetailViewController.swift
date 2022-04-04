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
	
	@IBOutlet var textView: UITextView!
	
	var toolbar: UIToolbar!
	var showToolbarButton: UIButton!
	
	var isToolbarShown = true {
		didSet {
			switch isToolbarShown {
			case true:
//				textView.inputAccessoryView?.isHidden = false
				textView.inputAccessoryView = toolbar
				textView.reloadInputViews()
				showToolbarButton.isHidden = true
			case false:
//				textView.inputAccessoryView?.isHidden = true
				textView.inputAccessoryView = nil
				textView.reloadInputViews()
				showToolbarButton.isHidden = false
			}
//			NotificationCenter.default.post(name: UIResponder.keyboardDidChangeFrameNotification, object: self, userInfo: [UIResponder.keyboardFrameEndUserInfoKey: textView])
		}
	}
	
//	@objc func displayInputAccessory() {
//		if isToolbarShown {
//			textView.inputAccessoryView = toolbar
//			textView.reloadInputViews()
//			showToolbarButton.isHidden = true
//		} else {
//			textView.inputAccessoryView = nil
//			textView.reloadInputViews()
//			showToolbarButton.isHidden = false
//		}
//	}
	
	override func viewDidLoad() {
		super.viewDidLoad()

		textView.attributedText = note.content
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(remove))
//		let shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))
//		self.navigationController?.isToolbarHidden = false
//		toolbarItems = [shareButton]
		
		let notificationCenter = NotificationCenter.default
		notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardDidHideNotification, object: nil)
		notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardDidChangeFrameNotification, object: nil)
//		notificationCenter.addObserver(self, selector: #selector(displayInputAccessory), name: UIResponder.keyboardWillShowNotification, object: nil)
		
		configInputAccessory()
		
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		let originalContent = note.content
		
		// If textView is empty, remove that file if it's already saved, or bail out if it's not
		guard !textView.text.isEmpty else {
			if let fileURL = note.fileURL {
				try! FileManager.default.removeItem(at: fileURL)
			}
			return
		}
		
		// If we are still here, then the textView is not empty. Bail out if content hasn't been changed
		guard originalContent != textView.attributedText else { return }
		
		note.content = textView.attributedText
		note.writeToDisk()
	}
	
	@objc func adjustForKeyboard(notification: Notification) {

		guard let userInfo = notification.userInfo else {
			return
		}
		
		let keyboardScreenEndFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
		print(keyboardScreenEndFrame)
		
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
	
	func configInputAccessory() {

		let spacer = UIBarButtonItem(systemItem: .flexibleSpace)

		let addTableButton = UIBarButtonItem(image: UIImage(systemName: "tablecells"), style: .plain, target: self, action: #selector(addTable))
		let adjustFontButton = UIBarButtonItem(image: UIImage(systemName: "textformat.alt"), style: .plain, target: self, action: #selector(adjustFont))
		let addChecklistButton = UIBarButtonItem(image: UIImage(systemName: "checklist"), style: .plain, target: self, action: #selector(addChecklist))
		let addImageButton = UIBarButtonItem(image: UIImage(systemName: "camera"), style: .plain, target: self, action: #selector(addImage))
		let addDrawingButton = UIBarButtonItem(image: UIImage(systemName: "pencil.tip.crop.circle"), style: .plain, target: self, action: #selector(addDrawing))
		let closeButton = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: self, action: #selector(hideToolbar))
		closeButton.tintColor = .gray
		
		// Set toolbar
		toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 45))
		
		toolbar.items = [addTableButton, spacer, adjustFontButton, spacer, addChecklistButton, spacer, addImageButton, spacer, addDrawingButton, spacer, closeButton]
		textView.inputAccessoryView = toolbar

		// Config button for showing toolbar items
		let plusIcon = UIImage(systemName: "plus.circle.fill")!.resized(factor: 2).withTintColor(.systemGray2)
		showToolbarButton = UIButton()
		
		showToolbarButton.setImage(plusIcon, for: .normal)
		showToolbarButton.addTarget(self, action: #selector(showToolbar), for: .touchUpInside)
		view.addSubview(showToolbarButton)
		
		showToolbarButton.translatesAutoresizingMaskIntoConstraints = false
		
		NSLayoutConstraint.activate([
			showToolbarButton.trailingAnchor.constraint(equalTo: textView.trailingAnchor, constant: -20),
			showToolbarButton.bottomAnchor.constraint(equalTo: textView.bottomAnchor, constant: 20),
		])

		showToolbarButton.isHidden = (!textView.isFirstResponder || !isToolbarShown)

	}
	
	@objc func addTable() {
		
	}
	
	@objc func adjustFont() {
		
	}
	
	@objc func addChecklist() {
		
	}
	
	@objc func addImage() {
		
	}
	
	@objc func addDrawing() {
		
	}
	
	@objc func hideToolbar() {
		isToolbarShown = false

	}
	
	@objc func showToolbar() {
		isToolbarShown = true

	}
}



