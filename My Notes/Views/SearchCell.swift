//
//  SearchCell.swift
//  My Notes
//
//  Created by Lei Gao on 2022/M/25.
//

import UIKit

class SearchCell: UITableViewCell {
	
	//    override func awakeFromNib() {
	//        super.awakeFromNib()
	//        // Initialization code
	//    }
	
	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
		
		// Configure the view for the selected state
	}
	
	init() {
		super.init(style: .default, reuseIdentifier: "Search")
		
		configCell()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		
		configCell()
	}
	
	func configCell() {
		let containerView = UIView()
		containerView.backgroundColor = .systemGray4
		containerView.layer.cornerRadius = 10

		
		let iconView = UIImageView(image: UIImage(systemName: "magnifyingglass"))
		containerView.addSubview(iconView)
		self.addSubview(containerView)

		let textField = UITextField()
		textField.placeholder = "Search"
		textField.translatesAutoresizingMaskIntoConstraints = false
		containerView.addSubview(textField)
				
		iconView.translatesAutoresizingMaskIntoConstraints = false
		containerView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			containerView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.45),
			containerView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
			containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
			containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0),
			
			iconView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
			iconView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
			// Set iconView's width equal to its height, otherwise it gets pulled wider since textField's leading and trailing anchor are both set.
			iconView.widthAnchor.constraint(equalTo: iconView.heightAnchor),
			
			textField.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 8),
			textField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
			textField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
		])
		
		// Try to remove separator line
//		self.separatorInset.left = self.bounds.size.width
		
		// This effectively disable select background color
		self.selectionStyle = .none

	}
	
}
