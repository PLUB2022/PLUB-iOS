//
//  ArchiveUploadCollectionViewCell.swift
//  PLUB
//
//  Created by 홍승현 on 2023/04/17.
//

import UIKit

final class ArchiveUploadCollectionViewCell: UICollectionViewCell {
  
  // MARK: - Properties
  
  static let identifier = "\(ArchiveUploadCollectionViewCell.self)"
  
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
    
  }
  
  private func setupConstraints() {
    
  }
  
  private func setupStyles() {
    
  }
}
