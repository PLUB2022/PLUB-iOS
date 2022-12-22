//
//  HomeCollectionViewCell.swift
//  PLUB
//
//  Created by 이건준 on 2022/10/06.
//

import UIKit
import Then
import SnapKit
import Kingfisher

class HomeCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "HomeCollectionViewCell"
    
    private let imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 10
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.gray.cgColor
    }
    
    private let interestLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 12, weight: .bold)
        $0.textColor = .black
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
        contentView.layer.masksToBounds = true
        _ = [imageView, interestLabel].map{ contentView.addSubview($0) }
        imageView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            print("width = \(contentView.frame.width)")
            make.height.equalTo(contentView.frame.width)
        }
        
        interestLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
    }
    
    public func configureUI(with model: InterestCollectionType) {
        interestLabel.text = model.title
        
        imageView.image = UIImage(named: model.imageNamed)
    }
}
