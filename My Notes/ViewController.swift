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
//	var searchView: UIView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Set up table header
		tableHeader = UILabel()
		tableHeader.text = headerString
		tableHeader.font = .systemFont(ofSize: 30)
		tableHeader.sizeToFit()		// tableHeaderView need to be given a height to be displayed
		tableView.tableHeaderView = tableHeader
		
		// Set up search view
//		searchView = UIView()
		
		let addButton = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(editNew))
		self.toolbarItems = [.flexibleSpace(), addButton]
		self.navigationController?.isToolbarHidden = false
	}
	
	override func scrollViewDidScroll(_ scrollView: UIScrollView) {

		if scrollView.contentOffset.y > -0 {
			tableHeader.isHidden = true
			self.title = headerString
		} else {
			tableHeader.isHidden = false
			self.title = ""
		}
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
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return notes.count
	}
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 2
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		if indexPath == [0, 0] {
			let cell = tableView.dequeueReusableCell(withIdentifier: "Search", for: indexPath)
			let iconView = UIImageView(image: UIImage(systemName: "magnifyingglass"))
			iconView.translatesAutoresizingMaskIntoConstraints = false
			cell.addSubview(iconView)
			NSLayoutConstraint.activate([
				iconView.centerYAnchor.constraint(equalTo: cell.centerYAnchor),
				iconView.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 15)
			])
			cell.heightAnchor.constraint(equalTo: cell.heightAnchor, multiplier: 1.5).isActive = true
			cell.layer.cornerRadius = 5
			cell.backgroundColor = .gray
//			cell.contentView.inset
//			tableView.contentInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
			cell.separatorInset.left = cell.bounds.size.width
			return cell
		} else {
			let cell = tableView.dequeueReusableCell(withIdentifier: "Note", for: indexPath)
			let string = notes[indexPath.row].content
			let subSequence = string.split(separator: "\n")
			let title = String(subSequence.first ?? "")
			let subTitle = (subSequence.count >= 2) ? String(subSequence[1]) : ""
			cell.textLabel?.text = title
			cell.detailTextLabel?.text = subTitle
			print(tableView.contentInset)
			return cell
		}
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
	
//	override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//
//		let searchView = UIView()
//		searchView.translatesAutoresizingMaskIntoConstraints = false
//		let iconView: UIImageView = UIImageView(image: UIImage(systemName: "magnifyingglass"))
//		searchView.addSubview(iconView)
//        let textField = UITextField()
//		searchView.addSubview(textField)
//		textField.translatesAutoresizingMaskIntoConstraints = false
//		textField.leadingAnchor.constraint(equalTo: iconView.trailingAnchor).isActive = true
//		textField.trailingAnchor.constraint(equalTo: searchView.trailingAnchor).isActive = true
//		textField.backgroundColor = .blue
//		return searchView
//	}
	
}

