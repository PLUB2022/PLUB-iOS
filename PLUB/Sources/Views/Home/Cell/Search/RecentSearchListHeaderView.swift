//
//  RecentSearchListHeaderView.swift
//  PLUB
//
//  Created by 이건준 on 2023/02/04.
//

import UIKit

import RxSwift
import SnapKit
import Then

protocol RecentSearchListHeaderViewDelegate: AnyObject {
  func didTappedRemoveAllButton()
}

class RecentSearchListHeaderView: UICollectionReusableView {
  
  static let identifier = "RecentSearchListHeaderView"
  private let disposeBag = DisposeBag()
  weak var delegate: RecentSearchListHeaderViewDelegate?
    
  private let titleLabel = UILabel().then {
    $0.textColor = .deepGray
    $0.font = .systemFont(ofSize: 16, weight: .semibold)
    $0.sizeToFit()
  }
  
  private let removeAllButton = UIButton(configuration: .plain()).then {
    var attString = AttributedString("모두 지우기")
    attString.font = .systemFont(ofSize: 14, weight: .regular)
    attString.foregroundColor = .deepGray
    $0.configuration?.attributedTitle = attString
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
    titleLabel.text = "최근 검색어"
    [titleLabel, removeAllButton].forEach { addSubview($0) }
    
    titleLabel.snp.makeConstraints {
      $0.left.centerY.equalToSuperview()
    }
    
    removeAllButton.snp.makeConstraints {
      $0.right.centerY.equalToSuperview()
    }
  }
  
  private func bind() {
    removeAllButton.rx.tap
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        owner.delegate?.didTappedRemoveAllButton()
      })
      .disposed(by: disposeBag)
  }
}
