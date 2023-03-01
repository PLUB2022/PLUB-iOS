//
//  BoardCollectionHeaderView.swift
//  PLUB
//
//  Created by 이건준 on 2023/03/02.
//

import UIKit

import SnapKit
import Then

final class BoardCollectionHeaderView: UICollectionReusableView {
  static let identifier = "BoardCollectionHeaderView"
  
  private let topStackView = UIStackView().then {
    $0.axis = .horizontal
    $0.spacing = 4
  }
  
  private let clipImageView = UIImageView().then {
    $0.contentMode = .scaleAspectFill
    $0.image = UIImage(named: "pin")
  }
  
  private let clipLabel = UILabel().then {
    $0.font = .subtitle
    $0.textColor = .black
    $0.text = "클립보드"
  }
  
  private let clipButton = UIButton().then {
    $0.setImage(UIImage(named: "rightIndicatorGray"), for: .normal)
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    backgroundColor = .white
    [topStackView].forEach { addSubview($0) }
    topStackView.snp.makeConstraints {
      $0.top.directionalHorizontalEdges.bottom.equalToSuperview()
      $0.height.equalTo(19.81)
    }
    
    [clipImageView, clipLabel, clipButton].forEach { topStackView.addArrangedSubview($0) }
  }
}
