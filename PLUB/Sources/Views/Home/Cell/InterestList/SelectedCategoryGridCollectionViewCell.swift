//
//  InterestListGridCollectionViewCell.swift
//  PLUB
//
//  Created by 이건준 on 2022/12/22.
//

import UIKit

class SelectedCategoryGridCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "SelectedCategoryGridCollectionViewCell"
    
    private let titleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 25, weight: .bold)
        $0.numberOfLines = 1
        $0.lineBreakMode = .byTruncatingTail
        $0.textColor = .white
        $0.textAlignment = .left
    }
    
    private let descriptionLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 15, weight: .regular)
        $0.numberOfLines = 1
        $0.lineBreakMode = .byTruncatingTail
        $0.textColor = .white
        $0.textAlignment = .left
    }
    
    private let seperatorView = UIView()
    
    private let selectedCategoryInfoView = SelectedCategoryInfoView(selectedCategoryInfoViewType: .Vertical)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        descriptionLabel.text = nil
        seperatorView.backgroundColor = nil
        selectedCategoryInfoView.backgroundColor = nil
    }
    
    private func configureUI() {
        contentView.backgroundColor = .black
        _ = [titleLabel, descriptionLabel, seperatorView, selectedCategoryInfoView].map{ contentView.addSubview($0) }
        selectedCategoryInfoView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.right.bottom.equalToSuperview().offset(-10)
            make.height.equalTo(100)
        }
        
        seperatorView.snp.makeConstraints { make in
            make.left.right.equalTo(selectedCategoryInfoView)
            make.bottom.equalTo(selectedCategoryInfoView.snp.top).offset(-10)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.left.right.equalTo(seperatorView)
            make.bottom.equalTo(seperatorView.snp.top).offset(-10)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.left.right.equalTo(seperatorView)
            make.bottom.equalTo(descriptionLabel.snp.top).offset(-10)
        }
    }
    
    public func configureUI(with model: SelectedCategoryCollectionViewCellModel) {
        titleLabel.text = model.title
        descriptionLabel.text = model.description
        seperatorView.backgroundColor = .white
        selectedCategoryInfoView.configureUI(with: model.selectedCategoryInfoViewModel)
    }
}
