//
//  RegisterInterestHeaderView.swift
//  PLUB
//
//  Created by 이건준 on 2022/10/10.
//

import UIKit
import SnapKit
import Then

struct RegisterInterestHeaderViewModel {
    let title: String
    let description: String
}

class RegisterInterestHeaderView: UITableViewHeaderFooterView {
    
    static let identifier = "RegisterInterestHeaderView"
    
    private let titleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 25, weight: .bold)
        $0.textColor = .label
    }
    
    private let descriptionLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 15, weight: .regular)
        $0.textColor = .secondaryLabel
        $0.numberOfLines = 2
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        _ = [titleLabel, descriptionLabel].map{ addSubview($0) }
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
//            make.bottom.equalTo(contentView.snp.centerY)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.left.equalTo(titleLabel.snp.left)
            make.top.equalTo(titleLabel.snp.bottom)
            make.height.equalTo(self.snp.height).dividedBy(2)
        }
        
//        descriptionLabel.snp.makeConstraints { make in
//            make.left.bottom.equalToSuperview()
//            make.top.equalTo(titleLabel.snp.bottom)
//        }
    }
    
    public func configureUI(with model: RegisterInterestHeaderViewModel) {
        titleLabel.text = model.title
        descriptionLabel.text = model.description
    }
}
