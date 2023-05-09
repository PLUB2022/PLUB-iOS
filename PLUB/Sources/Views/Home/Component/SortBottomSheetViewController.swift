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

final class BottomSheetFilterView: UIControl {
  
  // MARK: - Properties
  
  var isTapped: Bool = false {
    didSet {
      label.textColor      = isTapped ? .main : .black
      selectImageView.isHidden = !isTapped
    }
  }
  
  // MARK: - UI Components
  
  private let label = UILabel().then {
    $0.font = .body1
    $0.textColor = .black
    $0.sizeToFit()
  }
  
  private let selectImageView = UIImageView().then {
    $0.image = UIImage(named: "checkMain")
    $0.contentMode = .scaleAspectFit
  }
  
  // MARK: - Initializations
  
  init(text: String) {
    super.init(frame: .zero)
    configureUI(text: text)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Configuration
  
  private func configureUI(text: String) {
    [label, selectImageView].forEach { addSubview($0) }
    
    label.snp.makeConstraints {
      $0.leading.top.bottom.equalToSuperview()
    }
    
    selectImageView.snp.makeConstraints {
      $0.leading.equalTo(label.snp.trailing).offset(8)
      $0.top.bottom.equalToSuperview()
      $0.trailing.lessThanOrEqualToSuperview()
    }
    
    label.text = text
    selectImageView.isHidden = true
  }
}

extension Reactive where Base: BottomSheetFilterView {
  var tap: ControlEvent<Void> {
    controlEvent(.touchUpInside)
  }
}

protocol SortBottomSheetViewControllerDelegate: AnyObject {
  func didTappedSortButton(type: SortType)
}

final class SortBottomSheetViewController: BottomSheetViewController {
  
  weak var delegate: SortBottomSheetViewControllerDelegate?
  
  private let stackView = UIStackView().then {
    $0.spacing = 8
    $0.axis = .vertical
    $0.distribution = .fillEqually
  }
  
  private let titleLabel = UILabel().then {
    $0.text = "정렬"
    $0.textColor = .deepGray
    $0.font = .subtitle
    $0.sizeToFit()
  }
  
  private let popularButton = BottomSheetFilterView(text: SortType.popular.text)
  private let newButton = BottomSheetFilterView(text: SortType.new.text)
  
  override func setupLayouts() {
    super.setupLayouts()
    contentView.addSubview(stackView)
    [titleLabel, popularButton, newButton].forEach { stackView.addArrangedSubview($0) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    stackView.snp.makeConstraints {
      $0.top.equalToSuperview().inset(36)
      $0.leading.trailing.equalToSuperview().inset(24)
      $0.bottom.equalToSuperview().inset(24)
    }
    
    popularButton.snp.makeConstraints {
      $0.height.equalTo(32)
    }
    
    newButton.snp.makeConstraints {
      $0.height.equalTo(32)
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
  
  func configureUI(with type: SortType) {
    switch type {
    case .popular:
      popularButton.isTapped = true
      newButton.isTapped = false
    case .new:
      popularButton.isTapped = false
      newButton.isTapped = true
    }
  }
}
