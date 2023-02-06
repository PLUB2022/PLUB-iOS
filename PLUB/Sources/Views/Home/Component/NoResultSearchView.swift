//
//  NoResultSearchView.swift
//  PLUB
//
//  Created by 이건준 on 2023/02/06.
//

import UIKit

import SnapKit
import Then

class NoResultSearchView: UIView {
  
  enum SearchNotice: CaseIterable {
    case first
    case second
    
    var description: String {
      switch self {
      case .first:
        return "단어의 철자가 정확한지 확인해 보세요."
      case .second:
        return "검색어의 단어 수를 줄이거나, 보다 일반적인 검색어로\n 다시 검색해 보세요."
      }
    }
  }
  
  private let stackView = UIStackView().then {
    $0.axis = .vertical
    $0.alignment = .center
  }
  
  private let noResultImageView = UIImageView().then {
    $0.image = UIImage(named: "magnifierWithQuestionMark")
    $0.contentMode = .scaleAspectFill
  }
  
  private let noResultLabel = UILabel().then {
    $0.font = .subtitle
    $0.textColor = .black
    $0.numberOfLines = 0
    $0.sizeToFit()
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
    addSubview(stackView)
    stackView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
    
    [noResultImageView, noResultLabel].forEach { stackView.addArrangedSubview($0) }
    noResultImageView.snp.makeConstraints {
      $0.top.equalToSuperview().inset(166)
      $0.width.equalTo(162)
      $0.height.equalTo(136.23)
    }
    stackView.setCustomSpacing(32, after: noResultImageView)
    stackView.setCustomSpacing(8, after: noResultLabel)
    
    SearchNotice.allCases.forEach { notice in
      let label = UILabel()
      label.text = notice.description
      label.textColor = .deepGray
      label.font = .systemFont(ofSize: 12, weight: .medium)
      label.textAlignment = .left
      stackView.addArrangedSubview(label)
    }
  }
  
  public func configureUI(with model: String) {
    noResultLabel.text = "‘\(model)’에 대한 검색결과가 없어요."
  }
}
