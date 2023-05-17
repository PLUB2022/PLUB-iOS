//
//  AnnouncementCollectionViewCell.swift
//  PLUB
//
//  Created by 홍승현 on 2023/05/17.
//

import UIKit

import SnapKit
import Then

final class AnnouncementCollectionViewCell: UICollectionViewCell {
  
  // MARK: - UI Components
  
  private let wholeStackView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 4
  }
  
  private let headerStackView = UIStackView().then {
    $0.spacing = 8
    $0.alignment = .center
  }
  
  private let titleLabel = UILabel().then {
    $0.font = .body1
    $0.textColor = .black
    $0.setContentHuggingPriority(.required, for: .horizontal)
  }
  
  private let dateLabel = UILabel().then {
    $0.font = .overLine
    $0.textColor = .mediumGray
  }
  
  private let contentLabel = UILabel().then {
    $0.font = .body2
    $0.textColor = .black
    $0.numberOfLines = 2
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
    contentView.addSubview(wholeStackView)
    
    [headerStackView, contentLabel].forEach {
      wholeStackView.addArrangedSubview($0)
    }
    
    [titleLabel, dateLabel].forEach {
      headerStackView.addArrangedSubview($0)
    }
  }
  
  private func setupConstraints() {
    wholeStackView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview().inset(8)
    }
  }
  
  private func setupStyles() {
    contentView.backgroundColor = .white
    contentView.layer.cornerRadius = 10
  }
  
  func configure(with model: AnnouncementContent) {
    titleLabel.text = model.title
    
    if let postingDate = model.postingDate {
      dateLabel.text = DateFormatterFactory.dateWithDot.string(from: postingDate)
    } else {
      Log.error("날짜가 존재하지 않습니다. 백엔드와 얘기해보세요.")
      dateLabel.text = "날짜 없음"
    }
    contentLabel.text = model.content
  }
  
}
