//
//  InterestListGridCollectionViewCell.swift
//  PLUB
//
//  Created by 이건준 on 2022/12/22.
//

import UIKit

class InterestListGridCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "InterestListGridCollectionViewCell"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
        contentView.backgroundColor = .black
    }
    
    public func configureUI(with model: String) {
        
    }
}
