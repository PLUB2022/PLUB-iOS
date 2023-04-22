//
//  ArchiveUploadCell.swift
//  PLUB
//
//  Created by 홍승현 on 2023/04/22.
//

import UIKit

import SnapKit
import Then

final class ArchiveUploadCell: UICollectionViewCell {
  
  // MARK: - Properties
  
  static let identifier = "\(ArchiveUploadCell.self)"
  
  // MARK: - UI Components
  
  private let containerView = UIView().then {
    $0.backgroundColor = .lightGray
    $0.layer.cornerRadius = 10
  }
  
  private let stackView = UIStackView().then {
    $0.axis = .vertical
    $0.alignment = .center
    $0.spacing = 8
  }
  
  private let imageView = UIImageView(image: .init(systemName: "plus")).then {
    $0.tintColor = .black
  }
  
  private let label = UILabel().then {
    $0.text = "사진 추가"
    $0.textColor = .black
    $0.font = .body1
  }
  
  // MARK: - Initializations
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupLayouts()
    setupConstraints()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Configurations
  
  private func setupLayouts() {
    contentView.addSubview(containerView)
    containerView.addSubview(stackView)
    
    [imageView, label].forEach {
      stackView.addArrangedSubview($0)
    }
  }
  
  private func setupConstraints() {
    containerView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
    
    stackView.snp.makeConstraints {
      $0.center.equalToSuperview()
    }
    
    imageView.snp.makeConstraints {
      $0.size.equalTo(44)
    }
    
    label.snp.makeConstraints {
      $0.height.equalTo(21)
    }
  }
}
