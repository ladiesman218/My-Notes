//
//  ViewController.swift
//  My Notes
//
//  Created by Lei Gao on 2022/M/1.
//

import UIKit


class ViewController: UITableViewController {
	
	var notes = [Note]()
	var tableHeader: UILabel!
	var searchView: UIView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Set up table header
		tableHeader = UILabel()
		tableHeader.text = headerString
		tableHeader.font = .systemFont(ofSize: 30)
		tableHeader.sizeToFit()		// tableHeaderView need to be given a height to be displayed
		tableView.tableHeaderView = tableHeader
		
		// Set up search view
		searchView = UIView()
		
		let addButton = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(editNew))
		self.toolbarItems = [.flexibleSpace(), addButton]
		self.navigationController?.isToolbarHidden = false
	}
	
	override func scrollViewDidScroll(_ scrollView: UIScrollView) {

		print(scrollView.contentSize)
		if scrollView.contentOffset.y > -0 {
			tableHeader.isHidden = true
			self.title = headerString
		} else {
			tableHeader.isHidden = false
			self.title = ""
		}
	}
	
	override func viewWillAppear(_ animated: Bool) {
		
		notes = []
		
		if let files = try? FileManager.default.contentsOfDirectory(at: path, includingPropertiesForKeys: [], options: []) {
			for file in files {
//				try! FileManager.default.removeItem(atPath: file.path)
//				print(file)
				let data = try! Data(contentsOf: file)
				if let note = try? JSONDecoder().decode(Note.self, from: data) {
					notes.append(note)
				}
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
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return notes.count
	}
	
	override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
		
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "Note", for: indexPath)
		let string = notes[indexPath.row].content
		let subSequence = string.split(separator: "\n")
		let title = String(subSequence.first ?? "")
		let subTitle = (subSequence.count >= 2) ? String(subSequence[1]) : ""
		cell.textLabel?.text = title
		cell.detailTextLabel?.text = subTitle
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		guard let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "Note") as? DetailViewController else {
			print("Can't instantiate detail VC")
			return
		}
		detailVC.note = notes[indexPath.row]
		self.navigationController?.pushViewController(detailVC, animated: true)
	}
	
	override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		let action = UIContextualAction(style: .destructive, title: "Delete") { [weak self] action, table, handler in
			//@escaping (Bool) -> Void
			guard let note = self?.notes.remove(at: indexPath.row) else { return }
			note.removeFromDisk()
			
			tableView.deleteRows(at: [indexPath], with: .left)
		}
		return UISwipeActionsConfiguration(actions: [action])
	}
	
}

