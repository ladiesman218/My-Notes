//
//  ViewController.swift
//  My Notes
//
//  Created by Lei Gao on 2022/M/1.
//

import UIKit


class ViewController: UIViewController {
	
	var notes = [Note]() {
		didSet {
//			addCornerRadius(for: tableView)
		}
	}
	
	var tableHeader: UILabel!
	
	@IBOutlet var tableView: UITableView!

	override func viewDidLoad() {
		super.viewDidLoad()
		tableView.dataSource = self
		tableView.delegate = self
//		tableView.contentInset = UIEdgeInsets(top: 40, left: 0, bottom: 0, right: 0)
		// Setup background color
		view.backgroundColor = .systemGray6
		tableView.backgroundColor = view.backgroundColor
				
		// Setup table header
		tableHeader = UILabel()
		tableHeader.text = headerString
		tableHeader.backgroundColor = view.backgroundColor
		tableHeader.font = .systemFont(ofSize: 30)
		tableHeader.sizeToFit()		// tableHeaderView need to be given a height to be displayed
		tableView.tableHeaderView = tableHeader
				
		// Setup navigation bar buttons
		let addButton = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(editNew))
		self.toolbarItems = [.flexibleSpace(), addButton]
		self.navigationController?.isToolbarHidden = false
		
		self.navigationItem.backButtonTitle = headerString

	}
	
	override func viewWillAppear(_ animated: Bool) {
		// Everytime view will appear, re-load notes array, and reload tableView
		if let files = try? FileManager.default.contentsOfDirectory(at: path, includingPropertiesForKeys: []) {
			notes = files.map {
				let data = try! Data(contentsOf: $0)
				return try! JSONDecoder().decode(Note.self, from: data)
			}
		}
		tableView.reloadData()
		addCornerRadius(for: tableView)
	}
	
	@objc func editNew() {
		guard let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "Note") as? DetailViewController else {
			fatalError("Can't instantiate detailVC")
		}
		
		let note = Note(content: "", fileName: UUID().uuidString)
		note.writeToDisk()
		
		detailVC.note = note
		
		notes.append(note)
		
		self.navigationController?.pushViewController(detailVC, animated: true)
	}
		
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
	
	func addCornerRadius(for tableView: UITableView) {
		if tableView.numberOfRows(inSection: 0) == 2 {
			print("only one cell")
			let onlyCell = tableView.cellForRow(at: [0, 1])!
			onlyCell.layer.cornerRadius = 10
			return
		}
		tableView.visibleCells.forEach {
			$0.layer.cornerRadius = 0
		}
		let radius = CGFloat(20)
		if let firstCell = tableView.cellForRow(at: [0, 1]) {
			firstCell.layer.cornerRadius = radius
			firstCell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
		}
		let numberOfRows = tableView.numberOfRows(inSection: 0)
		if let lastCell = tableView.cellForRow(at: [0, numberOfRows - 1]) {
			lastCell.layer.cornerRadius = radius
			lastCell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
			
			// Remove last cell's separator
//			lastCell.separatorInset = UIEdgeInsets(top: 0, left: lastCell.bounds.size.width, bottom: 0, right: lastCell.bounds.size.width)

		}
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		// Account for search view
		return notes.count + 1
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		// Search field
		if indexPath == [0, 0] {
			let cell = tableView.dequeueReusableCell(withIdentifier: "Search", for: indexPath) as! SearchCell
			cell.backgroundColor = view.backgroundColor

			return cell
		} else {
			// Other normal cells
			let cell = tableView.dequeueReusableCell(withIdentifier: "Note", for: indexPath)
			let string = notes[indexPath.row - 1].content
			let subSequence = string.split(separator: "\n")
			let title = String(subSequence.first ?? "")
			let subTitle = (subSequence.count >= 2) ? String(subSequence[1]) : ""
			cell.textLabel?.text = title
			cell.detailTextLabel?.text = subTitle

			cell.layer.backgroundColor = UIColor.systemGray2.cgColor
			return cell
		}
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		guard indexPath != [0,0] else { return }
		guard let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "Note") as? DetailViewController else {
			print("Can't instantiate detail VC")
			return
		}
		detailVC.note = notes[indexPath.row - 1]

		self.navigationController?.pushViewController(detailVC, animated: true)
	}

	
	func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		
		// Disable swipe action for search, set for others
		if indexPath != [0, 0] {

			let action = UIContextualAction(style: .destructive, title: "Delete") { [weak self] action, table, handler in
				//@escaping (Bool) -> Void
				
				guard let note = self?.notes.remove(at: indexPath.row - 1) else { return }
				tableView.deleteRows(at: [indexPath], with: .left)	// This is for the row deletion animation
				note.removeFromDisk()
			}
			return UISwipeActionsConfiguration(actions: [action])
		}
		return UISwipeActionsConfiguration()
	}
	
	func scrollViewDidScroll(_ scrollView: UIScrollView) {

		if scrollView.contentOffset.y > tableHeader.frame.height {
			tableHeader.isHidden = true
			self.title = headerString

		} else {
			tableHeader.isHidden = false
			self.title = ""
		}
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if indexPath == [0, 0] {
			return 70
		}
		return tableView.rowHeight
	}
}
