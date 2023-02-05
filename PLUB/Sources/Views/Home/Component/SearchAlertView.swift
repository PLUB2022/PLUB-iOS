//
//  SearchAlertView.swift
//  PLUB
//
//  Created by 이건준 on 2023/01/27.
//

import UIKit

import SnapKit
import Then

final class SearchAlertView: UIView {
  
  private let emptyImageView = UIImageView().then {
    $0.image = UIImage(named: "magnifier")
    $0.contentMode = .scaleAspectFill
  }
  
  private let emptyLabel = UILabel().then {
    $0.text = "제목, 모임 이름, 키워드로 검색해보세요."
    $0.font = .subtitle
    $0.textColor = .black
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    backgroundColor = .background
    [emptyImageView, emptyLabel].forEach { addSubview($0) }
    emptyImageView.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.bottom.equalTo(snp.centerY).offset(32)
    }
    
    emptyLabel.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.top.equalTo(emptyImageView.snp.bottom).offset(32)
    }
  }
}
