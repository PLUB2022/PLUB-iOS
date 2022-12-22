//
//  InterestListNavigationBar.swift
//  PLUB
//
//  Created by 이건준 on 2022/12/22.
//

import UIKit
import RxCocoa

protocol InterestListNavigationBarDelegate: AnyObject {
    func didTappedBackButton()
    func didTappedSearchButton()
}

final class InterestListNavigationBar: UIView {
    
    public weak var delegate: InterestListNavigationBarDelegate?
    
    private let backButton = UIButton().then {
        $0.setImage(UIImage(named: "Back"), for: .normal)
    }
    
    private let titleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 30, weight: .bold)
        $0.textAlignment = .left
        $0.numberOfLines = 0
    }
    
    private let searchButton = UIButton().then {
        $0.setImage(UIImage(named: "Union"), for: .normal)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: -Configure
    private func configureUI() {
        backButton.addTarget(self, action: #selector(didTappedBackButton), for: .touchUpInside)
        searchButton.addTarget(self, action: #selector(didTappedSearchButton), for: .touchUpInside)
        
        _ = [backButton, titleLabel, searchButton].map{ addSubview($0) }
        backButton.snp.makeConstraints { make in
            make.left.centerY.equalToSuperview()
        }
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(backButton.snp.right)
        }
        searchButton.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.right.equalToSuperview().offset(-20)
        }
    }
    
    public func configureUI(with model: String) {
        titleLabel.text = model
    }
    
    // MARK: -Action
    @objc private func didTappedBackButton() {
        delegate?.didTappedBackButton()
    }
    
    @objc private func didTappedSearchButton() {
        delegate?.didTappedSearchButton()
    }
}
