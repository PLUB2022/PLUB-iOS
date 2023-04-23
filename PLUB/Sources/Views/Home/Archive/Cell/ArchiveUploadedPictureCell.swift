//
//  ArchiveUploadedPictureCell.swift
//  PLUB
//
//  Created by 홍승현 on 2023/04/17.
//

import UIKit

import SnapKit
import Then

final class ArchiveUploadedPictureCell: UICollectionViewCell {
  
  // MARK: - Properties
  
  static let identifier = "\(ArchiveUploadedPictureCell.self)"
  
  // MARK: - UI Components
  
  private let imageContainerView = UIView().then {
    $0.layer.cornerRadius = 10
    $0.backgroundColor = .deepGray
    $0.clipsToBounds = true
  }
  
  private let archiveImageView = UIImageView().then {
    $0.contentMode = .scaleAspectFill
  }
  
  private let cancelButton = UIButton().then {
    $0.setImage(.init(named: "xMarkCircle"), for: .normal)
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
    [imageContainerView, cancelButton].forEach {
      contentView.addSubview($0)
    }
    imageContainerView.addSubview(archiveImageView)
  }
  
  private func setupConstraints() {
    imageContainerView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
    
    archiveImageView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
    
    cancelButton.snp.makeConstraints {
      $0.top.trailing.equalToSuperview().inset(-8)
    }
  }
  
  private func setupStyles() {
    
  }
  
  func configure(with imageLink: String) {
    archiveImageView.kf.setImage(with: URL(string: imageLink))
  }
}
