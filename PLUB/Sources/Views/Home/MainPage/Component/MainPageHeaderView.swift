//
//  MainPageHeaderView.swift
//  PLUB
//
//  Created by 이건준 on 2023/03/03.
//

import UIKit

import RxSwift
import RxCocoa
import SnapKit
import Then

protocol MainPageHeaderViewDelegate: AnyObject {
  func didTappedMainPageBackButton()
}

class MainPageHeaderView: UIView {
  
  weak var delegate: MainPageHeaderViewDelegate?
  
  private let disposeBag = DisposeBag()
  
  private let horizontalStackView = UIStackView().then {
    $0.axis = .horizontal
    $0.spacing = 4
    $0.alignment = .trailing
  }
  
  private let backButton = UIButton().then {
    $0.setImage(UIImage(named: "leftIndicatorWhite"), for: .normal)
  }
  
  private let speakerButton = UIButton().then {
    $0.setImage(UIImage(named: "speakerWhite"), for: .normal)
  }
  
  private let photoStackButton = UIButton().then {
    $0.setImage(UIImage(named: "photoStackWhite"), for: .normal)
  }
  
  private let moreButton = UIButton().then {
    $0.setImage(UIImage(named: "verticalEllipsisWhite"), for: .normal)
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
    [backButton, horizontalStackView].forEach { addSubview($0) }
    
    backButton.snp.makeConstraints {
      $0.top.equalToSuperview().inset(13.5)
      $0.leading.equalToSuperview()
      $0.size.equalTo(32)
    }
    
    horizontalStackView.snp.makeConstraints {
      $0.top.equalToSuperview().inset(13.5)
      $0.trailing.equalToSuperview().inset(7)
      $0.leading.greaterThanOrEqualTo(backButton.snp.trailing)
      $0.height.equalTo(32)
    }
    
    [speakerButton, photoStackButton, moreButton].forEach { view in
      horizontalStackView.addArrangedSubview(view)
      view.snp.makeConstraints {
        $0.size.equalTo(32)
      }
    }
  }
  
  private func bind() {
    backButton.rx.tap
      .subscribe(with: self) { owner, _ in
        owner.delegate?.didTappedMainPageBackButton()
      }
      .disposed(by: disposeBag)
  }
}
