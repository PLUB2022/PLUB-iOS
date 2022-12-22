//
//  InterestListFilterHeaderView.swift
//  PLUB
//
//  Created by 이건준 on 2022/12/22.
//

import UIKit

protocol InterestListFilterHeaderViewDelegate: AnyObject {
    func didTappedInterestListFilterButton()
    func didTappedInterestListChartButton()
    func didTappedInterestListGridButton()
}

class InterestListFilterHeaderView: UICollectionReusableView {
    static let identifier = "InterestListFilterHeaderView"
    
    public weak var delegate: InterestListFilterHeaderViewDelegate?
    
    private let interestListFilterLabel = UILabel().then {
        $0.text = "전체"
        $0.font = .systemFont(ofSize: 20, weight: .bold)
    }
    
    private let interestListFilterButton = UIButton().then {
        $0.setImage(UIImage(named: "Filter"), for: .normal)
    }
    
    private let interestListChartButton = UIButton().then {
        $0.setImage(UIImage(named: "Chart"), for: .normal)
    }
    
    private let interesetListGridButton = UIButton().then {
        $0.setImage(UIImage(named: "Grid"), for: .normal)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        interestListFilterButton.addTarget(self, action: #selector(didTappedInterestListFilterButton), for: .touchUpInside)
        interestListChartButton.addTarget(self, action: #selector(didTappedInterestListChartButton), for: .touchUpInside)
        interesetListGridButton.addTarget(self, action: #selector(didTappedInterestListGridButton), for: .touchUpInside)
        
        _ = [interestListFilterLabel, interestListFilterButton, interestListChartButton, interesetListGridButton].map{ addSubview($0) }
        interestListFilterLabel.snp.makeConstraints { make in
            make.centerY.left.equalToSuperview()
        }
        
        interestListFilterButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(interestListFilterLabel.snp.right)
        }
        
        interesetListGridButton.snp.makeConstraints { make in
            make.centerY.right.equalToSuperview()
        }
        
        interestListChartButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalTo(interesetListGridButton.snp.left)
        }
    }
    
    @objc private func didTappedInterestListFilterButton() {
        delegate?.didTappedInterestListFilterButton()
    }
    
    @objc private func didTappedInterestListChartButton() {
        delegate?.didTappedInterestListChartButton()
    }
    
    @objc private func didTappedInterestListGridButton() {
        delegate?.didTappedInterestListGridButton()
    }
}
