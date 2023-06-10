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
//	// Make toolbar buttons
//	let spacer = UIBarButtonItem(systemItem: .flexibleSpace)
//
//	var addTableButton: UIBarButtonItem!
//	var adjustFontButton: UIBarButtonItem!
//	var addChecklistButton: UIBarButtonItem!
//	var addImageButton: UIBarButtonItem!
//	var addDrawingButton: UIBarButtonItem!
//	var addNewButton: UIBarButtonItem!
//	var closeButton: UIBarButtonItem!
	
	var isInputAccessoryToolbarShown = true {
		didSet {
			toggleInputAccessory(show: isInputAccessoryToolbarShown, animated: true)
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		textView.keyboardDismissMode = .interactive
		textView.delegate = self
		
		textView.attributedText = note.content
		textView.showsHorizontalScrollIndicator = false
		textView.textColor = .label
	
		configToolbars()
		textView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor).isActive = true
	}
	
	
	override func viewWillDisappear(_ animated: Bool) {
		navigationController?.toolbar.isHidden = false
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
	
	
	override func viewWillAppear(_ animated: Bool) {
		// Make toolbar buttons
		let spacer = UIBarButtonItem(systemItem: .flexibleSpace)

		let addCheckList = UIBarButtonItem(image: UIImage(systemName: "checklist"), style: .plain, target: self, action: #selector(addChecklist))
		let addImageButton = UIBarButtonItem(image: UIImage(systemName: "camera"), style: .plain, target: self, action: #selector(addImage))
		let addDrawingButton = UIBarButtonItem(image: UIImage(systemName: "pencil.tip.crop.circle"), style: .plain, target: self, action: #selector(addDrawing))
		let addNewButton = UIBarButtonItem(image: UIImage(systemName: "square.and.pencil"), style: .plain, target: self, action: #selector(addNewNote))

		// Config toolbar for navigation controller
		self.toolbarItems = [addCheckList, spacer, addImageButton, spacer, addDrawingButton, spacer, addNewButton]

		self.navigationController?.isToolbarHidden = false
	}
	
//	@objc func remove() {
//		textView.text = ""
//		self.navigationController?.popViewController(animated: true)
//	}
	
//	@objc func shareTapped() {
//		guard let text = textView.text, text != "" else { return }
//
//
//		let activityController = UIActivityViewController(activityItems: [text], applicationActivities: [
//		])
//		activityController.popoverPresentationController?.barButtonItem = navigationItem.leftBarButtonItem
//		self.present(activityController, animated: true)
//
//	}
	
	func configToolbars() {
		// Make toolbar buttons
		let spacer = UIBarButtonItem(systemItem: .flexibleSpace)

		let addTableButton = UIBarButtonItem(image: UIImage(systemName: "tablecells"), style: .plain, target: self, action: #selector(addTable))
		let adjustFontButton = UIBarButtonItem(image: UIImage(systemName: "textformat.alt"), style: .plain, target: self, action: #selector(adjustFont))
		let addChecklistButton = UIBarButtonItem(image: UIImage(systemName: "checklist"), style: .plain, target: self, action: #selector(addChecklist))
		let addImageButton = UIBarButtonItem(image: UIImage(systemName: "camera"), style: .plain, target: self, action: #selector(addImage))
		let addDrawingButton = UIBarButtonItem(image: UIImage(systemName: "pencil.tip.crop.circle"), style: .plain, target: self, action: #selector(addDrawing))
		let closeButton = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: self, action: #selector(hideInputAccessory(sender:)))
		closeButton.tintColor = .gray

		// Config textView's inputAccessoryView toolbar
		inputAccessoryToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 45))
		inputAccessoryToolbar.items = [spacer, addTableButton, spacer, adjustFontButton, spacer, addChecklistButton, spacer, addImageButton, spacer, addDrawingButton, spacer, closeButton, spacer]
		textView.inputAccessoryView = inputAccessoryToolbar
		
		// Config button for showing inputAccessoryView toolbar
		let plusIcon = UIImage(systemName: "plus.circle.fill")!.resized(factor: 2).withTintColor(.systemGray2)
		showInputAccessoryButton = UIButton()
		
		showInputAccessoryButton.setImage(plusIcon, for: .normal)
		showInputAccessoryButton.addTarget(self, action: #selector(showInputAccessory), for: .touchUpInside)
		view.addSubview(showInputAccessoryButton)
		
		showInputAccessoryButton.translatesAutoresizingMaskIntoConstraints = false
		
		NSLayoutConstraint.activate([
			showInputAccessoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -textView.bounds.width * 0.1),
			// constraint the button's bottom at textView's bottom, with an additional heigh of toolbar's height, so it's default position should be same with the toolbar's close button's.
			showInputAccessoryButton.bottomAnchor.constraint(equalTo: textView.bottomAnchor, constant: inputAccessoryToolbar.bounds.height)
		])

		showInputAccessoryButton.isHidden = (!textView.isFirstResponder || isInputAccessoryToolbarShown)
		
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
		isInputAccessoryToolbarShown = false
	}
	
		
	@objc func showInputAccessory() {
		isInputAccessoryToolbarShown = true
	}
	
	@objc func addNewNote() {
		
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
}



extension DetailViewController: UITextViewDelegate {

	func textViewDidBeginEditing(_ textView: UITextView) {
		navigationController?.toolbar.isHidden = true
		let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
		navigationItem.rightBarButtonItem = doneButton
		
	}
	func textViewDidEndEditing(_ textView: UITextView) {
		navigationController?.toolbar.isHidden = false
		navigationItem.rightBarButtonItem = nil
	}
	
	@objc func done() {
		toggleInputAccessory(show: true, animated: false)
		textView.resignFirstResponder()
	}
	
	
	func toggleInputAccessory(show: Bool, animated: Bool) {
		if show {
			textView.inputAccessoryView?.isHidden = false

			if animated {

				UIView.animate(withDuration: 0.3) {
					self.textView.inputAccessoryView!.transform = .identity
					self.showInputAccessoryButton.transform = .identity
				} completion: { finished in
					self.showInputAccessoryButton.isHidden = true
					
				}
			} else {
				textView.inputAccessoryView!.transform = .identity
				showInputAccessoryButton.transform = .identity
				showInputAccessoryButton.isHidden = true
			}
			
			
		} else {
			showInputAccessoryButton.isHidden = false
			if animated {
				UIView.animate(withDuration: 0.3) {
					self.showInputAccessoryButton.transform = CGAffineTransform(translationX: 0, y: -self.inputAccessoryToolbar.bounds.height / 2).rotated(by: .pi / 2)
					self.textView.inputAccessoryView?.transform = CGAffineTransform(translationX: 0, y: self.inputAccessoryToolbar.bounds.height)
				} completion: { finished in
					self.textView.inputAccessoryView?.isHidden = true
				}
			} else {
				showInputAccessoryButton.transform = CGAffineTransform(translationX: 0, y: -self.inputAccessoryToolbar.bounds.height / 2).rotated(by: .pi / 2)
				textView.inputAccessoryView?.transform = CGAffineTransform(translationX: 0, y: self.inputAccessoryToolbar.bounds.height)
				textView.inputAccessoryView?.isHidden = true
			}
		}
	}
}
