//
//  NotificationCollectionViewCell.swift
//  PLUB
//
//  Created by 홍승현 on 2023/04/25.
//

import UIKit

import SnapKit
import Then

final class NotificationCollectionViewCell: UICollectionViewListCell {
  
  // MARK: - Properties
  
  static let identifier = "\(NotificationCollectionViewCell.self)"
  
  // MARK: - UI Components
  
  private let containerView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 4
    $0.alignment = .leading
  }
  
  // MARK: Header
  
  private let headerStackView = UIStackView().then {
    $0.spacing = 4
  }
  
  private let typeImageView = UIImageView(image: .init(systemName: "megaphone")).then {
    $0.contentMode = .scaleAspectFit
  }
  
  private let titleLabel = UILabel().then {
    $0.text = "알림 제목"
    $0.textColor = .black
    $0.font = .body1
  }
  
  // MARK: Content
  
  private let contentLabel = UILabel().then {
    $0.text = "알림 내용"
    $0.textColor = .black
    $0.font = .caption2
  }
  
  // MARK: Footer
  
  private let footerStackView = UIStackView().then {
    $0.spacing = 8
  }
  
  private let descriptionLabel = UILabel().then {
    $0.text = "상세 설명 내용"
    $0.textColor = .deepGray
    $0.font = .overLine
  }
  
  private let dateTimeLabel = UILabel().then {
    $0.text = "2023. 04. 25 | 11:44"
    $0.textColor = .mediumGray
    $0.font = .overLine
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
    contentView.addSubview(containerView)
    
    [headerStackView, contentLabel, footerStackView].forEach {
      containerView.addArrangedSubview($0)
    }
    
    [typeImageView, titleLabel].forEach {
      headerStackView.addArrangedSubview($0)
    }
    
    [descriptionLabel, dateTimeLabel].forEach {
      footerStackView.addArrangedSubview($0)
    }
  }
  
  private func setupConstraints() {
    containerView.snp.makeConstraints {
      $0.directionalVerticalEdges.equalToSuperview().inset(8)
      $0.directionalHorizontalEdges.equalToSuperview().inset(16)
    }
    
    typeImageView.snp.makeConstraints {
      $0.size.equalTo(16)
    }
  }
  
  private func setupStyles() {
    contentView.backgroundColor = .background
  }
}
