//
//  SortBottomSheetViewController.swift
//  PLUB
//
//  Created by 이건준 on 2023/01/31.
//

import UIKit

import RxSwift
import RxCocoa
import SnapKit
import Then

class SortBottomSheetView: UIControl {
  
  private let type: SortType
  
  var isTapped: Bool = false {
    didSet {
      sortLabel.textColor = isTapped ? .main : .black
      selectImageView.isHidden = !isTapped
    }
  }
  
  private let sortLabel = UILabel().then {
    $0.font = .body1
    $0.textColor = .black
    $0.sizeToFit()
  }
  
  private let selectImageView = UIImageView().then {
    $0.image = UIImage(named: "sortSelect")
    $0.contentMode = .scaleAspectFit
  }
  
  init(type: SortType) {
    self.type = type
    super.init(frame: .zero)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    [sortLabel, selectImageView].forEach { addSubview($0) }
    
    sortLabel.snp.makeConstraints { make in
      make.left.top.bottom.equalToSuperview()
    }
    
    selectImageView.snp.makeConstraints { make in
      make.left.equalTo(sortLabel.snp.right)
      make.top.bottom.equalToSuperview()
      make.right.lessThanOrEqualToSuperview()
    }
    
    sortLabel.text = type.text
    selectImageView.isHidden = true
  }
}

extension Reactive where Base: SortBottomSheetView {
  var tap: ControlEvent<Void> {
    controlEvent(.touchUpInside)
  }
}

class SortBottomSheetViewController: BottomSheetViewController {
  
  private let grabber = UIView().then {
    $0.backgroundColor = .mediumGray
    $0.layer.cornerRadius = 6
    $0.layer.masksToBounds = true
  }
  
  private let stackView = UIStackView().then {
    $0.spacing = 15.5
    $0.axis = .vertical
    $0.distribution = .fillEqually
    $0.isLayoutMarginsRelativeArrangement = true
    $0.layoutMargins = .init(top: 36, left: 16, bottom: 24, right: 16)
  }
  
  private let titleLabel = UILabel().then {
    $0.text = "정렬"
    $0.textColor = .deepGray
    $0.font = .subtitle
    $0.sizeToFit()
  }
  
  private let popularButton = SortBottomSheetView(type: .popular)
  private let newButton = SortBottomSheetView(type: .new)
  
  override func setupStyles() {
    super.setupStyles()
    
    popularButton.isTapped = true
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    [grabber, stackView].forEach { contentView.addSubview($0) }
    [titleLabel, popularButton, newButton].forEach { stackView.addArrangedSubview($0) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    grabber.snp.makeConstraints { make in
      make.top.equalToSuperview().inset(8)
      make.centerX.equalToSuperview()
      make.width.equalTo(48)
      make.height.equalTo(4)
    }
    
    stackView.snp.makeConstraints { make in
      make.top.equalTo(grabber.snp.bottom).offset(8)
      make.left.right.bottom.equalToSuperview()
    }
  }
}
