//
//  DetailViewController.swift
//  My Notes
//
//  Created by Lei Gao on 2022/M/1.
//

import UIKit

class DetailViewController: UIViewController {
	
	var note: Note!
	
	@IBOutlet var textView: UITextView!
	
	var inputAccessoryToolbar: UIToolbar!
	var showInputAccessoryButton: UIButton!
	
	lazy var textViewToKeyboardConstriant = NSLayoutConstraint(item: textView!, attribute: .bottom, relatedBy: .equal, toItem: textView.keyboardLayoutGuide, attribute: .top, multiplier: 1.0, constant: -0)
	
	lazy var textViewToNavToolbarConstraint = NSLayoutConstraint(item: textView!, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: -navigationController!.toolbar.bounds.height)
	
		
	var isInputAccessoryToolbarShown = true {
		didSet {
			switch isInputAccessoryToolbarShown {
			case true:
				// set and unset inputAccessoryView will trigger keyboardDidHideNotification notification automatically, while set inputAccessory.isHidden won't.
				self.textView.inputAccessoryView?.isHidden = false

				UIView.animate(withDuration: 0.3) {
					self.textView.inputAccessoryView!.transform = .identity
					self.showInputAccessoryButton.transform = .identity
				} completion: { finished in
					self.showInputAccessoryButton.isHidden = true
				}
			case false:
				showInputAccessoryButton.isHidden = false
				
				UIView.animate(withDuration: 1.3) {
					self.showInputAccessoryButton.transform = CGAffineTransform(translationX: 0, y: -self.inputAccessoryToolbar.bounds.height).rotated(by: .pi / 2)
					self.textView.inputAccessoryView?.transform = CGAffineTransform(translationX: 0, y: self.inputAccessoryToolbar.bounds.height)
				} completion: { finished in
					self.textView.inputAccessoryView?.isHidden = true
				}
			}
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		textView.keyboardDismissMode = .interactive
		textView.delegate = self
		
		textView.attributedText = note.content
		textView.showsHorizontalScrollIndicator = false
	
		configToolbars()
		textViewToNavToolbarConstraint.isActive = true
		
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
	
	func configToolbars() {
		// Make toolbar buttons
		let spacer = UIBarButtonItem(systemItem: .flexibleSpace)
		
		let addTableButton = UIBarButtonItem(image: UIImage(systemName: "tablecells"), style: .plain, target: self, action: #selector(addTable))
		let adjustFontButton = UIBarButtonItem(image: UIImage(systemName: "textformat.alt"), style: .plain, target: self, action: #selector(adjustFont))
		let addChecklistButton = UIBarButtonItem(image: UIImage(systemName: "checklist"), style: .plain, target: self, action: #selector(addChecklist))
		let addImageButton = UIBarButtonItem(image: UIImage(systemName: "camera"), style: .plain, target: self, action: #selector(addImage))
		let addDrawingButton = UIBarButtonItem(image: UIImage(systemName: "pencil.tip.crop.circle"), style: .plain, target: self, action: #selector(addDrawing))
		let addNewButton = UIBarButtonItem(image: UIImage(systemName: "square.and.pencil"), style: .plain, target: self, action: #selector(addNewNote))
		let closeButton = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: self, action: #selector(hideInputAccessory(sender:)))
		closeButton.tintColor = .gray
		
		// Config textView's inputAccessoryView toolbar
		inputAccessoryToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 45))
		
		inputAccessoryToolbar.items = [addTableButton, spacer, adjustFontButton, spacer, addChecklistButton, spacer, addImageButton, spacer, addDrawingButton, spacer, closeButton]
		textView.inputAccessoryView = inputAccessoryToolbar
		
		// Config button for showing inputAccessoryView toolbar
		let plusIcon = UIImage(systemName: "plus.circle.fill")!.resized(factor: 2).withTintColor(.systemGray2)
		showInputAccessoryButton = UIButton()
		
		showInputAccessoryButton.setImage(plusIcon, for: .normal)
		showInputAccessoryButton.addTarget(self, action: #selector(showInputAccessory), for: .touchUpInside)
		view.addSubview(showInputAccessoryButton)
		
		showInputAccessoryButton.translatesAutoresizingMaskIntoConstraints = false
		
		NSLayoutConstraint.activate([
			showInputAccessoryButton.trailingAnchor.constraint(equalTo: textView.trailingAnchor, constant: -15),
			// constraint the button's bottom at textView's bottom, with an additional heigh of toolbar's height, so it's default position should be same with the toolbar's close button's.
			showInputAccessoryButton.bottomAnchor.constraint(equalTo: textView.bottomAnchor, constant: inputAccessoryToolbar.bounds.height)
		])

		showInputAccessoryButton.isHidden = (!textView.isFirstResponder || isInputAccessoryToolbarShown)
		
		// Config toolbar for navigation controller
		self.toolbarItems = [addTableButton, spacer, addImageButton, spacer, addDrawingButton, spacer, addNewButton]
		
		self.navigationController?.isToolbarHidden = false

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
	
	
	
	@objc func hideInputAccessory(sender: UIBarButtonItem) {
		self.isInputAccessoryToolbarShown = false
	}
	
		
	@objc func showInputAccessory() {
		self.isInputAccessoryToolbarShown = true
	}
	
	@objc func addNewNote() {
		
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
}



extension DetailViewController: UITextViewDelegate {
//	func textViewDidBeginEditing(_ textView: UITextView) {
//		textViewToNavToolbarConstraint.isActive = false
//		textViewToKeyboardConstriant.isActive = true
//
//		navigationController?.toolbar.isHidden = true
//		view.setNeedsLayout()
//		view.setNeedsDisplay()
//	}
	func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
		textViewToNavToolbarConstraint.isActive = false
		textViewToKeyboardConstriant.isActive = true

		navigationController?.toolbar.isHidden = true
		view.setNeedsLayout()
		view.setNeedsDisplay()
		
		return true
	}
	
	
	func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
		textViewToKeyboardConstriant.isActive = false
		textViewToNavToolbarConstraint.isActive = true
		navigationController?.isToolbarHidden = false
		
		view.setNeedsLayout()
		view.setNeedsDisplay()
		return true
	}
}
