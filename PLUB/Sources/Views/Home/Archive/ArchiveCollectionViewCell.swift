//
//  ArchiveCollectionViewCell.swift
//  PLUB
//
//  Created by 홍승현 on 2023/03/10.
//

import UIKit

import RxSwift
import RxCocoa
import SnapKit
import Then

final class ArchiveCollectionViewCell: UICollectionViewCell {
  
  // MARK: - Properties
  
  static let identifier = "\(ArchiveCollectionViewCell.self)"
  
  // MARK: - UI Components
  
  // MARK: Leading Indicator Part
  
  private let leadingIndicatorStackView = UIStackView().then {
    $0.axis = .vertical
    $0.alignment = .center
  }
  
  private let circleImageView = UIImageView(image: .init(named: "pointWhite")).then {
    $0.contentMode = .scaleAspectFit
  }
  
  private let verticalLineView = UIView().then {
    $0.backgroundColor = .lightGray
  }
  
  // MARK: Content Part
  
  private let containerView = UIView().then {
    $0.backgroundColor = .white
    $0.layer.cornerRadius = 10
  }
  
  private let firstContentImageView = UIImageView().then {
    $0.backgroundColor = .deepGray
    $0.layer.cornerRadius = 6
  }
  private let secondContentImageView = UIImageView().then {
    $0.backgroundColor = .deepGray
    $0.alpha = 0.5
    $0.layer.cornerRadius = 6
  }
  private let thirdContentImageView = UIImageView().then {
    $0.backgroundColor = .deepGray
    $0.alpha = 0.1
    $0.layer.cornerRadius = 6
  }
  
  // MARK: - Initializations
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupLayouts()
    setupConstraints()
    setupStyles()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Configurations
  
  private func setupLayouts() {
    contentView.addSubview(leadingIndicatorStackView)
    contentView.addSubview(containerView)
    
    [circleImageView, verticalLineView].forEach {
      leadingIndicatorStackView.addArrangedSubview($0)
    }
    
    // add image Views to `containerView`
    [thirdContentImageView, secondContentImageView, firstContentImageView].forEach {
      containerView.addSubview($0)
    }
  }
  
  private func setupConstraints() {
    leadingIndicatorStackView.snp.makeConstraints {
      $0.leading.top.bottom.equalToSuperview()
    }
    
    circleImageView.snp.makeConstraints {
      $0.size.equalTo(10)
    }
    
    verticalLineView.snp.makeConstraints {
      $0.width.equalTo(2)
    }
    
    containerView.snp.makeConstraints {
      $0.top.trailing.equalToSuperview()
      $0.leading.equalTo(leadingIndicatorStackView.snp.trailing).offset(8)
      $0.bottom.equalToSuperview().inset(8)
    }
    
    // images
    firstContentImageView.snp.makeConstraints {
      $0.leading.equalToSuperview().inset(8)
      $0.centerY.equalToSuperview()
      $0.size.equalTo(80)
    }
    
    secondContentImageView.snp.makeConstraints {
      $0.leading.equalTo(firstContentImageView.snp.leading).offset(12)
      $0.centerY.equalTo(firstContentImageView)
      $0.size.equalTo(firstContentImageView.snp.size).offset(-8) // 첫 번째 이미지에서 8을 뺀 크기
    }
    
    thirdContentImageView.snp.makeConstraints {
      $0.leading.equalTo(secondContentImageView.snp.leading).offset(12)
      $0.centerY.equalTo(firstContentImageView)
      $0.size.equalTo(secondContentImageView.snp.size).offset(-8) // 두 번째 이미지에서 8을 뺀 크기
    }
    
    
  }
  
  private func setupStyles() {
    
  }
}
