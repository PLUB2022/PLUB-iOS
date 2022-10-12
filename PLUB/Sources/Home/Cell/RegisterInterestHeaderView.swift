//
//  RegisterInterestHeaderView.swift
//  PLUB
//
//  Created by 이건준 on 2022/10/10.
//

import UIKit
import SnapKit
import Then

class RegisterInterestHeaderView: UITableViewHeaderFooterView {
    
    static let identifier = "RegisterInterestHeaderView"
    
    private let titleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 25, weight: .bold)
        $0.textColor = .label
        $0.text = "취미모임 관심사 등록"
    }
    
    private let descriptionLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 15, weight: .medium)
        $0.textColor = .secondaryLabel
        $0.numberOfLines = 2
        $0.text = "PLUB 에게 당신의 관심사를 알려주세요.\n관심사 위주로 모임을 추천해 드려요!"
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        print("height = \(contentView.frame.height)")
        _ = [titleLabel, descriptionLabel].map{ contentView.addSubview($0) }
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview().offset(15)
//            make.bottom.equalTo(contentView.snp.centerY)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.left.equalTo(titleLabel.snp.left)
            make.top.equalTo(titleLabel.snp.bottom)
            make.height.equalTo(contentView.snp.height).dividedBy(2)
        }
        
//        descriptionLabel.snp.makeConstraints { make in
//            make.left.bottom.equalToSuperview()
//            make.top.equalTo(titleLabel.snp.bottom)
//        }
    }
}
