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
    
    sortLabel.snp.makeConstraints {
      $0.left.top.bottom.equalToSuperview()
    }
    
    selectImageView.snp.makeConstraints {
      $0.left.equalTo(sortLabel.snp.right)
      $0.top.bottom.equalToSuperview()
      $0.right.lessThanOrEqualToSuperview()
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

protocol SortBottomSheetViewControllerDelegate: AnyObject {
  func didTappedSortButton(type: SortType)
}

class SortBottomSheetViewController: BottomSheetViewController {
  
  weak var delegate: SortBottomSheetViewControllerDelegate?
  
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
    
    grabber.snp.makeConstraints {
      $0.top.equalToSuperview().inset(8)
      $0.centerX.equalToSuperview()
      $0.width.equalTo(48)
      $0.height.equalTo(4)
    }
    
    stackView.snp.makeConstraints {
      $0.top.equalTo(grabber.snp.bottom).offset(8)
      $0.left.right.bottom.equalToSuperview()
    }
  }
  
  override func bind() {
    super.bind()
    
    popularButton.rx.tap
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        owner.popularButton.isTapped = true
        owner.newButton.isTapped = false
        owner.delegate?.didTappedSortButton(type: .popular)
      })
      .disposed(by: disposeBag)
    
    newButton.rx.tap
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        owner.popularButton.isTapped = false
        owner.newButton.isTapped = true
        owner.delegate?.didTappedSortButton(type: .new)
      })
      .disposed(by: disposeBag)
  }
}
