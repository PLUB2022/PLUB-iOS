//
//  InterestListChartCollectionViewCell.swift
//  PLUB
//
//  Created by 이건준 on 2022/12/22.
//

import UIKit
import SnapKit
import Then

struct InterestListChartCollectionViewCellModel {
    
}

class InterestListChartCollectionViewCell: UICollectionViewCell {
    static let identifier = "InterestListChartCollectionViewCell"
    
    private let titleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 30, weight: .bold)
        $0.textColor = .white
    }
    
    private let descriptionLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 15, weight: .regular)
        $0.textColor = .white
    }
    
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
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    public func configureUI(with model: String) {
        
    }
}
