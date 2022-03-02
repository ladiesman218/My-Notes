//
//  ViewController.swift
//  My Notes
//
//  Created by Lei Gao on 2022/M/1.
//

import UIKit

class ViewController: UITableViewController {
	
	var path: URL!
	var notes = [Note]()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.title = "备忘录"
		let addButton = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(editNew))
		self.toolbarItems = [.flexibleSpace(), addButton]
		self.navigationController?.isToolbarHidden = false
	}
	
	override func viewWillAppear(_ animated: Bool) {
		
		notes = []
		
		path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
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
		
		let fileURL = path.appendingPathComponent(UUID().uuidString)
		let note = Note(content: "", fileURL: fileURL)
		note.writeToDisk()
		
		detailVC.note = note
		
		notes.append(note)
		
		self.navigationController?.pushViewController(detailVC, animated: true)
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return notes.count
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
			// Can't directly delete note.fileURL, since that contains a random device UUID, which may change during different simulation
			let fileName = note.fileURL.lastPathComponent
			guard let url = self?.path.appendingPathComponent(fileName) else { return }
			try! FileManager.default.removeItem(at: url)
			tableView.deleteRows(at: [indexPath], with: .left)
		}
		return UISwipeActionsConfiguration(actions: [action])
	}
	
}

