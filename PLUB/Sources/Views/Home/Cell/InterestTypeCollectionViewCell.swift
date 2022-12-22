//
//  InterestTypeCollectionViewCell.swift
//  PLUB
//
//  Created by 이건준 on 2022/11/24.
//

import UIKit
import Then
import SnapKit

class InterestTypeCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "InterestTypeCollectionViewCell"
    
    private let interestTypeLabel = UILabel().then {
        $0.textColor = .gray
        $0.textAlignment = .center
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.gray.cgColor
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
        contentView.backgroundColor = .white
        
        contentView.addSubview(interestTypeLabel)
        interestTypeLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    public func configureUI(with model: InterestCollectionType) {
        interestTypeLabel.text = model.title
    }
}
