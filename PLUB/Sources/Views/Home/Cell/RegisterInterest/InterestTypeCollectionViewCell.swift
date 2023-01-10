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
    
    public var isTapped: Bool = false {
        didSet {
            contentView.backgroundColor = isTapped ? .main : .white
            interestTypeLabel.textColor = isTapped ? .white : .gray
        }
    }
    
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        interestTypeLabel.text = nil
    }
    
    private func configureUI() {
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.black.cgColor
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
