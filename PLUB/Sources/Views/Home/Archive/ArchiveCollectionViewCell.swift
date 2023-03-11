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
    
    [circleImageView, verticalLineView].forEach {
      leadingIndicatorStackView.addArrangedSubview($0)
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
  }
  
  private func setupStyles() {
    
  }
}
