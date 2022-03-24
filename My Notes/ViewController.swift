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
		
		// Set up table header
		tableHeader = UILabel()
		tableHeader.text = headerString
		tableHeader.font = .systemFont(ofSize: 30)
		tableHeader.sizeToFit()		// tableHeaderView need to be given a height to be displayed
		tableView.tableHeaderView = tableHeader
		
		// Set up search view
//		searchView.backgroundColor = .blue
		
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
		return notes.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "Note", for: indexPath)
		let string = notes[indexPath.row].content
		let subSequence = string.split(separator: "\n")
		let title = String(subSequence.first ?? "")
		let subTitle = (subSequence.count >= 2) ? String(subSequence[1]) : ""
		cell.textLabel?.text = title
		cell.detailTextLabel?.text = subTitle
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		guard let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "Note") as? DetailViewController else {
			print("Can't instantiate detail VC")
			return
		}
		detailVC.note = notes[indexPath.row]
		self.navigationController?.pushViewController(detailVC, animated: true)
	}
	
	func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		let action = UIContextualAction(style: .destructive, title: "Delete") { [weak self] action, table, handler in
			//@escaping (Bool) -> Void
			guard let note = self?.notes.remove(at: indexPath.row) else { return }
			note.removeFromDisk()
			
			tableView.deleteRows(at: [indexPath], with: .left)
		}
		return UISwipeActionsConfiguration(actions: [action])
	}
	
	func scrollViewDidScroll(_ scrollView: UIScrollView) {

		if scrollView.contentOffset.y > -0 {
			tableHeader.isHidden = true
			self.title = headerString
		} else {
			tableHeader.isHidden = false
			self.title = ""
		}
	}
	
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let view = UIView()
		view.backgroundColor = .yellow
		return view
	}
	
	
}
