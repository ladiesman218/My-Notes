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
	
	var isToolbarShown = true {
		didSet {
			switch isToolbarShown {
			case true:
				// set and unset inputAccessoryView will trigger keyboardDidHideNotification notification automatically, while set inputAccessory.isHidden won't.
s				textView.inputAccessoryView = toolbar
			case false:
				textView.inputAccessoryView = nil
			}
			textView.reloadInputViews()
//			textView.setNeedsDisplay()
			textView.setNeedsLayout()
			textView.layoutIfNeeded()

			
			// Remove all animations for showToolbarButton otherwise showToolbarButton will have a going down transition.
			self.showToolbarButton.layer.removeAllAnimations()
			
			showToolbarButton.bottomAnchor.constraint(equalTo: textView.bottomAnchor, constant: -toolbar.bounds.height).isActive = true

			showToolbarButton.isHidden = isToolbarShown
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
			//			showToolbarButton.bottomAnchor.constraint(equalTo: textView.bottomAnchor, constant: -15),
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
	
	lazy var transform: CGAffineTransform = {
		
		var transform = CGAffineTransform(rotationAngle: -.pi / 3)
		transform = transform.concatenating(CGAffineTransform(translationX: 0, y: toolbar.bounds.height / 2))
		return transform
		
	}()
	
	@objc func hideToolbar(sender: UIBarButtonItem) {
		UIView.animate(withDuration: 3.15) {
			sender. transform = self.transform.inverted()
		} completion: { finished in
			self.isToolbarShown = false
		}
	}
	
	
//	var transform = CGAffineTransform(rotationAngle: -.pi / 3)
//	transform = transform.concatenating(CGAffineTransform(translationX: 0, y: toolbar.bounds.height / 2))
	
	@objc func showToolbar() {
		
		UIView.animate(withDuration: 0.15) {
			self.showToolbarButton.transform = self.transform
		} completion: { _ in
			self.showToolbarButton.transform = .identity
			
			self.isToolbarShown = true
		}
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
}



