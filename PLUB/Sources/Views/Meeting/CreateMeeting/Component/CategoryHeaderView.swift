//
//  CategoryHeaderView.swift
//  PLUB
//
//  Created by 김수빈 on 2023/01/30.
//

import UIKit

import SnapKit
import RxSwift

final class CategoryHeaderView: UIView {
  private let disposeBag = DisposeBag()
  
  private let titleLabel = UILabel().then {
    $0.text = """
    취미에 진심인 우리!
    어떤 플러빙을 시작해 볼까요?
    """
    $0.numberOfLines = 2
    $0.textColor = .black
    $0.font = .h4
  }
  
  private let countStackView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 2
    $0.alignment = .center
  }
  
  private let countLabel = UILabel().then {
    $0.text = "0개"
    $0.textColor = .mediumGray
    $0.font = .h3
    $0.textAlignment = .center
  }
  
  private let selectedLabel = UILabel().then {
    $0.text = "선택됨"
    $0.textColor = .mediumGray
    $0.font = .caption2
    $0.textAlignment = .center
  }
  
  init() {
    super.init(frame: .zero)
    setupLayouts()
    setupConstraints()
    setupStyles()
    bind()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

private extension CategoryHeaderView {
  func setupLayouts() {
    [titleLabel, countStackView].forEach {
      addSubview($0)
    }
    
    [countLabel, selectedLabel].forEach {
      countStackView.addArrangedSubview($0)
    }
  }
  
  func setupConstraints() {
    titleLabel.snp.makeConstraints {
      $0.top.equalToSuperview()
      $0.leading.equalToSuperview().inset(16)
    }
    
    countStackView.snp.makeConstraints {
      $0.top.equalToSuperview().inset(3)
      $0.trailing.equalToSuperview().inset(16)
      $0.width.equalTo(54)
    }
    
    countLabel.snp.makeConstraints {
      $0.height.equalTo(24)
    }
    
    selectedLabel.snp.makeConstraints {
      $0.height.equalTo(14.4)
    }
  }
  
  func setupStyles() {
    backgroundColor = .background
  }
  
  func bind() {
  }
}

extension CategoryHeaderView {
  func updateSelectedCount(count: Int) {
    countLabel.text = "\(count)개"
    countLabel.textColor = count == 0 ? .mediumGray : .main
    selectedLabel.textColor = count == 0 ? UIColor.mediumGray : UIColor.deepGray
  }
}
