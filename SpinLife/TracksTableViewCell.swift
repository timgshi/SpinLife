//
//  TracksTableViewCell.swift
//  SpinLife
//
//  Created by Tim Shi on 2017/04/29.
//  Copyright © 2017 Tim Shi. All rights reserved.
//

import UIKit
import SnapKit

class TracksTableViewCell: UITableViewCell {

    lazy var nameLabel: UILabel = self.makeNameLabel()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.sharedInitializer()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.sharedInitializer()
    }

    func sharedInitializer() {
        self.backgroundColor = UIColor.white
        self.selectionStyle = .none

        self.contentView.addSubview(self.nameLabel)

        self.setNeedsUpdateConstraints()
    }
    override func updateConstraints() {

        let margin = CGFloat(15.0)

        self.nameLabel.snp.updateConstraints { (make) in
            make.edges.equalTo(self.contentView).inset(margin)
        }

        super.updateConstraints()
    }

    private func makeNameLabel() -> UILabel {
        let label = UILabel()
        label.numberOfLines = 1
        label.textAlignment = .left
        return label
    }
    
}
