//
//  RecommendedMeetingCollectionViewCell.swift
//  PLUB
//
//  Created by 이건준 on 2022/10/06.
//

import UIKit
import Then
import SnapKit

protocol RecommendedMeetingCollectionViewCellDelegate: AnyObject {
    func didTappedRegisterInterestView()
}

class RecommendedMeetingCollectionViewCell: UICollectionViewCell {
    static let identifier = "RecommendedMeetingCollectionViewCell"
    
    weak var delegate: RecommendedMeetingCollectionViewCellDelegate?
    
    private let registerInterestView = RegisterInterestView().then {
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 20
        $0.backgroundColor = .secondarySystemBackground
        $0.isUserInteractionEnabled = true
    }
    
    class RegisterInterestView: UIView {
        
        private let label = UILabel().then {
            $0.text = "관심사 등록 하기"
            $0.textColor = .gray
            $0.font = .systemFont(ofSize: 25, weight: .bold)
        }
        
        private let imageView = UIImageView().then {
            let config = UIImage.SymbolConfiguration(pointSize: 40, weight: .bold)
            let image = UIImage(systemName: "plus.circle", withConfiguration: config)
            $0.image = image
            $0.contentMode = .scaleAspectFill
            $0.tintColor = .gray
        }
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            _ = [label, imageView].map{ addSubview($0) }
            label.snp.makeConstraints { make in
                make.bottom.equalTo(self.snp.centerY).offset(-10)
                make.centerX.equalToSuperview()
            }
            
            imageView.snp.makeConstraints { make in
                make.top.equalTo(label.snp.bottom).offset(10)
                make.centerX.equalToSuperview()
            }
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
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
        contentView.layer.cornerRadius = 10
        contentView.addSubview(registerInterestView)
        registerInterestView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTappedRegisterButton))
        registerInterestView.addGestureRecognizer(gesture)
    }
    
    @objc private func didTappedRegisterButton() {
        delegate?.didTappedRegisterInterestView()
    }
}
