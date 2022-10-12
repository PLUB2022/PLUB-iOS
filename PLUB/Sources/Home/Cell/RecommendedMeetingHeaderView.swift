//
//  RecommendedMeetingHeaderView.swift
//  PLUB
//
//  Created by 이건준 on 2022/10/06.
//

import UIKit
import SnapKit
import Then

class RecommendedMeetingHeaderView: UICollectionReusableView {
    
    static let identifier = "RecommendedMeetingHeaderView"
    
    private let titleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 30, weight: .bold)
        $0.text = "추천 모임"
        $0.textColor = .black
    }
    
    private let descriptionLabel = UILabel().then {
        $0.text = "관심사 등록한 내용을 기반으로 모임을 추천해드려요!"
        $0.textColor = .gray
        $0.font = .systemFont(ofSize: 15, weight: .thin)
    }
    
    private let settingButton = UIButton().then {
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold)
        let image = UIImage(systemName: "gearshape", withConfiguration: config)
        $0.setImage(image, for: .normal)
        $0.tintColor = .black
        $0.contentMode = .scaleAspectFill
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        _ = [titleLabel, descriptionLabel, settingButton].map{ addSubview($0) }
        titleLabel.snp.makeConstraints { make in
            make.top.left.equalToSuperview()
            make.bottom.equalTo(self.snp.centerY)
        }
        
        settingButton.snp.makeConstraints { make in
            make.top.bottom.equalTo(titleLabel)
            make.left.equalTo(titleLabel.snp.right)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.left.equalTo(titleLabel.snp.left)
            make.top.equalTo(titleLabel.snp.bottom)
        }
    }
    
    public func configureUI(with model: String) {
        titleLabel.text = model
    }
}

