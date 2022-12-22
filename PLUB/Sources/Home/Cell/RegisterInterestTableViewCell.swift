//
//  RegisterInterestTableViewCell.swift
//  PLUB
//
//  Created by 이건준 on 2022/10/07.
//

import UIKit
import SnapKit
import Then

struct RegisterInterestTableViewCellModel {
    let imageName: String
    let title: String
    let description: String
    let isExpanded: Bool
}

class RegisterInterestTableViewCell: UITableViewCell {
    
    static let identifier = "RegisterInterestTableViewCell"
    
    var isExpanded: Bool = false {
        didSet {
            isExpanded ? indicatorButton.setImage(UIImage(named: "Vector 2-1"), for: .normal) : indicatorButton.setImage(UIImage(named: "Vector 2"), for: .normal)
        }
    }
    
    private let interestImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 10
    }
    
    private let titleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 18, weight: .bold)
        $0.textColor = .black
    }
    
    private let descriptionLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 13, weight: .regular)
        $0.textColor = .gray
    }
    
    private let indicatorButton = UIButton().then {
        $0.setImage(UIImage(named: "Vector 2"), for: .normal)
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        interestImageView.image = nil
        titleLabel.text = nil
        descriptionLabel.text = nil
        indicatorButton.setImage(nil, for: .normal)
    }
    
    private func configureUI() {
        contentView.backgroundColor = .systemBackground
        contentView.layer.masksToBounds = true
        contentView.layer.cornerRadius = 10
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.gray.cgColor
        
        _ = [interestImageView, titleLabel, descriptionLabel, indicatorButton].map{ contentView.addSubview($0) }
        interestImageView.snp.makeConstraints { make in
//            make.centerY.equalToSuperview()
            make.top.left.equalToSuperview().offset(5)
            make.bottom.equalToSuperview().offset(-5)
            make.width.equalTo(80)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(interestImageView.snp.top)
            make.bottom.equalTo(interestImageView.snp.centerY)
            make.left.equalTo(interestImageView.snp.right).offset(10)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.left.equalTo(titleLabel.snp.left)
            make.top.equalTo(titleLabel.snp.bottom)
            make.bottom.equalTo(interestImageView.snp.bottom)
//            make.height.equalTo(50)
        }
        
        indicatorButton.snp.makeConstraints { make in
            make.centerY.equalTo(interestImageView.snp.centerY)
//            make.top.bottom.equalToSuperview()
            make.right.equalToSuperview().offset(-20)
        }
    }
    
    public func configureUI(with model: RegisterInterestTableViewCellModel) {
        interestImageView.image = UIImage(named: model.imageName)
        titleLabel.text = model.title
//        descriptionLabel.text = "PLUB! 에게 관심사를 선택해주세요"
        descriptionLabel.text = model.description
        isExpanded = model.isExpanded
    }
}

