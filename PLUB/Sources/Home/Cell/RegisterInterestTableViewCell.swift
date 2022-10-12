//
//  RegisterInterestTableViewCell.swift
//  PLUB
//
//  Created by 이건준 on 2022/10/07.
//

import UIKit
import SnapKit
import Then

class RegisterInterestTableViewCell: UITableViewCell {
    
    static let identifier = "RegisterInterestTableViewCell"
    
    private let interestImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 10
    }
    
    private let titleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 15, weight: .bold)
        $0.textColor = .black
    }
    
    private let descriptionLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 10, weight: .regular)
        $0.textColor = .gray
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        contentView.backgroundColor = .white
        contentView.layer.masksToBounds = true
        contentView.layer.cornerRadius = 10
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.black.cgColor
        accessoryType = .disclosureIndicator
        _ = [interestImageView, titleLabel, descriptionLabel].map{ contentView.addSubview($0) }
        interestImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.top.left.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().offset(-10)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(interestImageView.snp.top)
            make.bottom.equalTo(contentView.snp.centerY)
            make.left.equalTo(interestImageView.snp.right).offset(10)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.left.equalTo(titleLabel.snp.left)
            make.top.equalTo(contentView.snp.centerY)
        }
    }
    
    public func configureUI(with model: String) {
        interestImageView.image = UIImage(systemName: "heart.fill")
        titleLabel.text = "예술"
        descriptionLabel.text = "PLUB! 에게 관심사를 선택해주세요"
    }
}
