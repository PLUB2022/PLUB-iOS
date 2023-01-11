//
//  RecommendedMeetingCollectionViewCell.swift
//  PLUB
//
//  Created by 이건준 on 2022/10/06.
//

import UIKit

import SnapKit
import Then

protocol RecommendedMeetingCollectionViewCellDelegate: AnyObject {
    func didTappedRegisterInterestView()
}

class RecommendedMeetingCollectionViewCell: UICollectionViewCell {

  static let identifier = "RecommendedMeetingCollectionViewCell"
  
  weak var delegate: RecommendedMeetingCollectionViewCellDelegate?
  
  private let registerInterestView = RegisterInterestView().then {
    $0.layer.masksToBounds = true
    $0.layer.cornerRadius = 20
    $0.backgroundColor = .lightGray
    $0.isUserInteractionEnabled = true
  }
  
  class RegisterInterestView: UIView {
    
    private let label = UILabel().then {
      $0.text = "관심사 등록 하기"
      $0.textColor = .deepGray
      $0.font = .h5
    }
    
    private let imageView = UIImageView().then {
      let config = UIImage.SymbolConfiguration(pointSize: 40, weight: .bold)
      let image = UIImage(systemName: "plus.circle", withConfiguration: config)
      $0.image = image
      $0.contentMode = .scaleAspectFill
      $0.tintColor = .deepGray
    }
    
    override init(frame: CGRect) {
      super.init(frame: frame)
      backgroundColor = .lightGray
      [label, imageView].forEach { addSubview($0) }
      label.snp.makeConstraints {
        $0.bottom.equalTo(self.snp.centerY).offset(-10)
        $0.centerX.equalToSuperview()
      }
      
      imageView.snp.makeConstraints {
        $0.top.equalTo(label.snp.bottom).offset(10)
        $0.centerX.equalToSuperview()
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
    contentView.backgroundColor = .lightGray
    contentView.addSubview(registerInterestView)
    registerInterestView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
    
    @objc private func didTappedRegisterButton() {
        delegate?.didTappedRegisterInterestView()
    }
}
