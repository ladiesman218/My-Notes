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
	
	var toolbar: UIToolbar!
	var showToolbarButton: UIButton!
	
	lazy var rotateUp: CGAffineTransform = {
		var transform = CGAffineTransform(rotationAngle: .pi / 2)
		transform = transform.concatenating(CGAffineTransform(translationX: 0, y: -toolbar.bounds.height))
		return transform
	}()
	
	lazy var slideOutToBottom: CGAffineTransform = {
		var transform = CGAffineTransform(translationX: 0, y: self.toolbar.bounds.height)
		return transform
	}()
		
	var isToolbarShown = true {
		didSet {
			switch isToolbarShown {
			case true:
				// set and unset inputAccessoryView will trigger keyboardDidHideNotification notification automatically, while set inputAccessory.isHidden won't.
				self.textView.inputAccessoryView?.isHidden = false

				UIView.animate(withDuration: 0.3) {
					self.textView.inputAccessoryView!.transform = .identity
					self.showToolbarButton.transform = .identity
				} completion: { finished in
					self.showToolbarButton.isHidden = true
				}
			case false:
				showToolbarButton.isHidden = false
				
				UIView.animate(withDuration: 0.3) {
					self.showToolbarButton.transform = self.rotateUp
					self.textView.inputAccessoryView?.transform = self.slideOutToBottom
				} completion: { finished in
					self.textView.inputAccessoryView?.isHidden = true
				}
			}
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		textView.keyboardDismissMode = .interactive
		textView.bottomAnchor.constraint(equalTo: textView.keyboardLayoutGuide.topAnchor).isActive = true
		
		textView.attributedText = note.content
		textView.showsHorizontalScrollIndicator = false
		
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(remove))
		//		let shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))
		self.navigationController?.isToolbarHidden = true
		//		toolbarItems = [shareButton]
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
		let closeButton = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: self, action: #selector(hideToolbar(sender:)))
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
			showToolbarButton.trailingAnchor.constraint(equalTo: textView.trailingAnchor, constant: -15),
			// constraint the button's bottom at textView's bottom, with an additional heigh of toolbar's height, so it's default position should be same with the toolbar's close button's.
			showToolbarButton.bottomAnchor.constraint(equalTo: textView.bottomAnchor, constant: toolbar.bounds.height)
		])
//		showToolbarButton.bottomAnchor.constraint(equalTo: textView.bottomAnchor, constant: -toolbar.bounds.height).isActive = true

//		showToolbarButton.isHidden = isToolbarShown
		showToolbarButton.isHidden = (!textView.isFirstResponder || isToolbarShown)
		
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
	
	
	
	@objc func hideToolbar(sender: UIBarButtonItem) {
		self.isToolbarShown = false

	}
	
		
	@objc func showToolbar() {
		self.isToolbarShown = true
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
}



