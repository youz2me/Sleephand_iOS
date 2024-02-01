//
//  BLETableViewCell.swift
//  ControlMusicToSleep
//
//  Created by YOUJIM on 2/1/24.
//

import UIKit

class BLETableViewCell: UITableViewCell {
    
    var cellID = "BLETableViewCell"
    
    var aboveView: UIView = UIView().then {
        $0.backgroundColor = .gray
    }
    
    var BLENameLabel: UILabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14)
        $0.textColor = .black
        $0.textAlignment = .left
    }
    
    var underView: UIView = UIView().then {
        $0.backgroundColor = .gray
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        [
            aboveView,
            BLENameLabel,
            underView
        ].forEach { self.contentView.addSubview($0) }
        
        aboveView.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.height.equalTo(0.5)
        }
        
        BLENameLabel.snp.makeConstraints {
            $0.top.equalTo(aboveView.snp.bottom).offset(25)
            $0.left.equalToSuperview().offset(15)
        }
        
        underView.snp.makeConstraints {
            $0.top.equalTo(BLENameLabel.snp.bottom).offset(24)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(0.5)
            $0.bottom.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
