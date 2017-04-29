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
    lazy var tempoLabel: UILabel = self.makeTempoLabel()

    var tempo: Int = 0 {
        didSet {
            self.tempoLabel.text = "Tempo: \(tempo)bpm"
        }
    }

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
        self.contentView.addSubview(self.tempoLabel)

        self.setNeedsUpdateConstraints()
    }

    override func updateConstraints() {

        let margin = CGFloat(15.0)

        self.nameLabel.snp.updateConstraints { (make) in
            make.left.equalTo(self.contentView).offset(margin)
            make.right.equalTo(self.contentView).offset(-margin)
            make.top.equalTo(self.contentView).offset(margin)
            make.bottom.equalTo(self.tempoLabel.snp.top)
        }
        self.tempoLabel.snp.updateConstraints { (make) in
            make.left.equalTo(self.nameLabel)
            make.right.equalTo(self.nameLabel)
            make.top.equalTo(self.nameLabel.snp.bottom)
            make.bottom.equalTo(self.contentView).offset(-margin)
        }

        super.updateConstraints()
    }

    private func makeNameLabel() -> UILabel {
        let label = UILabel()
        label.numberOfLines = 1
        label.textAlignment = .left
        return label
    }

    private func makeTempoLabel() -> UILabel {
        let label = UILabel()
        label.numberOfLines = 1
        label.textAlignment = .left
        return label
    }
    
}
