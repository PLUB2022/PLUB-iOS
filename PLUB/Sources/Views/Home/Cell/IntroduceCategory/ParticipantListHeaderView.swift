//
//  ParticipantListHeaderView.swift
//  PLUB
//
//  Created by 이건준 on 2023/01/17.
//

import UIKit

import SnapKit
import Then

final class ParticipantListHeaderView: UICollectionReusableView {
  
  static let identifier = "ParticipantListHeaderView"
  
  private let headerLabel = UILabel().then {
    $0.textColor = .black
    $0.font = .h5
    $0.textAlignment = .justified
    $0.text = "With us!"
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    addSubview(headerLabel)
    headerLabel.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
}
