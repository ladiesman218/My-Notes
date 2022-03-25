//
//  ViewController.swift
//  My Notes
//
//  Created by Lei Gao on 2022/M/1.
//

import UIKit


class ViewController: UIViewController {
	
	var notes = [Note]()
	
	var tableHeader: UILabel!
//	@IBOutlet weak var searchView: UIView!
//	var searchView: UIView!
	
	@IBOutlet var tableView: UITableView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		tableView.dataSource = self
		tableView.delegate = self
		
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
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		// Account for search view
		return notes.count + 1
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		// Search field
		if indexPath == [0, 0] {
			let cell = tableView.dequeueReusableCell(withIdentifier: "Search", for: indexPath)

			let imageView = UIImageView(image: UIImage(systemName: "magnifyingglass"))
			cell.addSubview(imageView)
			
			imageView.translatesAutoresizingMaskIntoConstraints = false
			NSLayoutConstraint.activate([
				imageView.centerYAnchor.constraint(equalTo: cell.centerYAnchor),
				imageView.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 10)
			])
			
			cell.backgroundColor = .systemGray4
			cell.layer.cornerRadius = 10
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
			
			// Add topleft and topright corner radius for 1st cell(aside from search view so compare to 1 rather than 0, and bottomLeft and bottomRight corner radius for last cell
			var corners = UIRectCorner()
			if indexPath.row == 1 {
				corners.update(with: .topLeft)
				corners.update(with: .topRight)
			}
			
			if indexPath.row == tableView.numberOfRows(inSection: 0) - 1 {
				corners.update(with: .bottomLeft)
				corners.update(with: .bottomRight)
			}
			
			let path = UIBezierPath(roundedRect:cell.bounds, byRoundingCorners:[corners], cornerRadii: CGSize(width: 10, height: 10))
			
			let maskLayer = CAShapeLayer()
			maskLayer.path = path.cgPath
			cell.layer.mask = maskLayer

			cell.layer.backgroundColor = UIColor.systemBackground.cgColor
			return cell
		}
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
				print(indexPath.row)
				guard let note = self?.notes.remove(at: indexPath.row - 1) else { return }
				note.removeFromDisk()
				
				tableView.deleteRows(at: [indexPath], with: .left)	// This is for the row deletion animation
				tableView.reloadData()	// This is for triggering corner radius re-draw
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
	
//	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//		if indexPath == [0, 0] {
//			return 100
//		}
//		return tableView.rowHeight
//	}
	
}
