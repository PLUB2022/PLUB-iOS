//
//  BoardClipboardHeaderView.swift
//  PLUB
//
//  Created by 이건준 on 2023/03/10.
//

import UIKit

import RxSwift
import SnapKit
import Then

final class BoardClipboardHeaderView: UICollectionReusableView {
  
  static let identifier = "BoardClipboardHeaderView"
  private let disposeBag = DisposeBag()
  
  private let horizontalStackView = UIStackView().then {
    $0.axis = .horizontal
    $0.spacing = 4
  }
  
  private let pinImageView = UIImageView().then {
    $0.image = UIImage(named: "pin")
    $0.contentMode = .scaleAspectFill
  }
  
  private let clipboardLabel = UILabel().then {
    $0.text = "클립보드"
    $0.font = .subtitle
    $0.textColor = .black
  }
  
  private let clipboardButton = UIButton().then {
    $0.setImage(UIImage(named: "rightIndicatorGray"), for: .normal)
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
    bind()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    [pinImageView, clipboardLabel, clipboardButton].forEach { horizontalStackView.addArrangedSubview($0) }
    pinImageView.snp.makeConstraints {
      $0.size.equalTo(24)
    }
    
    [horizontalStackView].forEach { addSubview($0) }
    
    clipboardButton.snp.makeConstraints {
      $0.size.equalTo(32)
    }
    
    horizontalStackView.snp.makeConstraints {
      $0.top.equalToSuperview().inset(9)
      $0.directionalHorizontalEdges.bottom.equalToSuperview().inset(10)
    }
    
  }
  
  private func bind() {
    clipboardButton.rx.tap
      .subscribe(onNext: {
        
      })
      .disposed(by: disposeBag)
  }
}
