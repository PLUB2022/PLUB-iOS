//
//  ArchiveDetailCollectionViewCell.swift
//  PLUB
//
//  Created by 홍승현 on 2023/04/16.
//

import UIKit

import Kingfisher
import SnapKit
import Then

final class ArchiveDetailColletionViewCell: UICollectionViewCell {
  
  // MARK: - Properties
  
  static let identifier = "\(ArchiveDetailColletionViewCell.self)"
  
  // MARK: - UI Components
  
  private let imageView = UIImageView().then {
    $0.contentMode = .scaleAspectFill
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
  
  // MARK: - Configuration
  
  private func setupLayouts() {
    contentView.addSubview(imageView)
  }
  
  private func setupConstraints() {
    imageView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
  }
  
  private func setupStyles() {
    contentView.backgroundColor = .deepGray
    contentView.layer.cornerRadius = 10
    contentView.clipsToBounds = true
  }
  
  func configure(with imageString: String) {
    guard let url = URL(string: imageString) else { return }
    imageView.kf.setImage(with: url)
  }
}
