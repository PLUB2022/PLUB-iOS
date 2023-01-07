//
//  IntroduceCategoryNavigationbar.swift
//  PLUB
//
//  Created by 이건준 on 2023/01/03.
//

import UIKit
import RxCocoa

protocol IntroduceCategoryNavigationBarDelegate: AnyObject {
    func didTappedBackButton()
    func didTappedComponentButton()
}

final class IntroduceCategoryNavigationBar: UIView {
    
    public weak var delegate: IntroduceCategoryNavigationBarDelegate?
    
    private let backButton = UIButton().then {
        $0.setImage(UIImage(named: "Back"), for: .normal)
    }
    
    private let componentButton = UIButton().then {
        $0.setImage(UIImage(named: "Component 1"), for: .normal)
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
        componentButton.addTarget(self, action: #selector(didTappedComponentButton), for: .touchUpInside)
        
        _ = [backButton, componentButton].map{ addSubview($0) }
        backButton.snp.makeConstraints { make in
            make.left.centerY.equalToSuperview()
        }
        
        componentButton.snp.makeConstraints { make in
            make.right.centerY.equalToSuperview()
//            make.top.bottom.equalToSuperview()
//            make.right.equalToSuperview().offset(-20)
        }
    }
    
    // MARK: -Action
    @objc private func didTappedBackButton() {
        delegate?.didTappedBackButton()
    }
    
    @objc private func didTappedComponentButton() {
        delegate?.didTappedComponentButton()
    }
}
