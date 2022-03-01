//
//  ViewController.swift
//  My Notes
//
//  Created by Lei Gao on 2022/M/1.
//

import UIKit

class ViewController: UITableViewController {

	var files: [URL] = [URL]()
	var path: URL!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.title = "备忘录"
		let addButton = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(editNew))
		self.toolbarItems = [.flexibleSpace(), addButton]
		self.navigationController?.isToolbarHidden = false
	}
	
	override func viewWillAppear(_ animated: Bool) {

		files = []
		
		path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
		if let files = try? FileManager.default.contentsOfDirectory(at: path, includingPropertiesForKeys: [], options: []) {
			for file in files {
				if let _ = try? String(contentsOf: file) {
					self.files.append(file)
				}
			}
		}
		tableView.reloadData()
	}

	@objc func editNew() {
		guard let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "Note") as? DetailViewController else {
			print("Can't instantiate detail VC")
			return
		}
		
		let fileURL = path.appendingPathComponent(UUID().uuidString)

		guard FileManager.default.createFile(atPath: fileURL.path, contents: Data(), attributes: nil) else {
			print("Can't create new file")
			return
		}
		detailVC.fileURL = fileURL
		
		self.navigationController?.pushViewController(detailVC, animated: true)
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return files.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "Note", for: indexPath)
		let string = try! String(contentsOf: files[indexPath.row])
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
		
		detailVC.fileURL = files[indexPath.row]
		self.navigationController?.pushViewController(detailVC, animated: true)
	}
	
	override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		let action = UIContextualAction(style: .destructive, title: "Delete") { [weak self] action, table, handler in
			//@escaping (Bool) -> Void
			guard let file = self?.files[indexPath.row] else { return }
			self?.files.remove(at: indexPath.row)
			guard let _ = try? FileManager.default.removeItem(at: file) else { return }
			tableView.deleteRows(at: [indexPath], with: .left)
		}
		return UISwipeActionsConfiguration(actions: [action])
	}
	
	
}

