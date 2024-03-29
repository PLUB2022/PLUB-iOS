//
//  SearchView.swift
//  PLUB
//
//  Created by 김수빈 on 2023/01/21.
//

import UIKit

import SnapKit

final class SearchView: UIView {
  private let searchImage = UIImageView().then {
    $0.image = UIImage(named: "searchGray")
    $0.contentMode = .scaleAspectFit
  }
  
  let textField = UITextField().then {
    $0.attributedPlaceholder = NSAttributedString(
      string: "장소를 검색해주세요",
      attributes: [
        .foregroundColor : UIColor.deepGray,
        .font : UIFont.body3
      ]
    )
    $0.textColor = .black
    $0.font = .body3
  }
  
  init() {
    super.init(frame: .zero)
    setupLayouts()
    setupConstraints()
    setupStyles()
  }
  
  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupLayouts() {
    [searchImage, textField].forEach {
      addSubview($0)
    }
  }
  
  private func setupConstraints() {
    searchImage.snp.makeConstraints {
      $0.centerY.equalToSuperview()
      $0.size.equalTo(20)
      $0.leading.equalToSuperview().inset(8)
    }
    
    textField.snp.makeConstraints {
      $0.leading.equalTo(searchImage.snp.trailing).offset(8)
      $0.trailing.equalToSuperview().inset(8)
      $0.top.bottom.equalToSuperview()
    }
  }
  
  private func setupStyles() {
    layer.cornerRadius = 8
    backgroundColor = .lightGray
  }
  
  func setupStyles(state: Bool) {
    if state {
      backgroundColor = .white
      searchImage.image = UIImage(named: "searchBlack")
    } else {
      backgroundColor = .lightGray
      searchImage.image = UIImage(named: "searchGray")
    }
  }
}
