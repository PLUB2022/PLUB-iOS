//
//  NoLocationView.swift
//  PLUB
//
//  Created by 김수빈 on 2023/01/21.
//

import UIKit

import SnapKit

final class NoLocationView: UIView {
  private let noLocationImage = UIImageView().then {
    $0.image = UIImage(named: "noSearchData")
    $0.contentMode = .scaleAspectFit
  }
  
  private let titleLabel = UILabel().then {
    $0.textColor = .black
    $0.font = .subtitle
    $0.numberOfLines = 0
    $0.textAlignment = .center
  }
  
  private let subtitleLabel = UILabel().then {
    $0.text = """
    · 단어의 철자가 정확한지 확인해 보세요.
    · 검색어의 단어 수를 줄이거나, 보다 일반적인 검색어로
      다시 검색해 보세요.
    """
    $0.textColor = .deepGray
    $0.font = .caption
    $0.numberOfLines = 0
    $0.textAlignment = .left
    $0.addLineSpacing()
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
    [noLocationImage, titleLabel, subtitleLabel].forEach {
      addSubview($0)
    }
  }
  
  private func setupConstraints() {
    noLocationImage.snp.makeConstraints {
      $0.top.equalToSuperview()
      $0.centerX.equalToSuperview()
      $0.width.equalTo(166)
      $0.height.equalTo(100)
    }
    
    titleLabel.snp.makeConstraints {
      $0.top.equalTo(noLocationImage.snp.bottom).offset(32)
      $0.leading.trailing.equalToSuperview().inset(73)
    }
    
    subtitleLabel.snp.makeConstraints {
      $0.top.equalTo(titleLabel.snp.bottom).offset(8)
      $0.leading.trailing.equalToSuperview().inset(60)
      $0.bottom.equalToSuperview()
    }
  }
  
  private func setupStyles() {
    backgroundColor = .background
  }
  
  func setTitleAttributeText(searchText: String) {
    let purpleCharacters = NSAttributedString(
      string: "'\(searchText)'",
      attributes: [.foregroundColor: UIColor.main]
    )
    
    let blackCharacters = NSAttributedString(
      string: "에 대한 검색결과가 없어요.",
      attributes: [.foregroundColor: UIColor.black]
    )
    
    titleLabel.attributedText = NSMutableAttributedString(attributedString: purpleCharacters).then {
      $0.append(blackCharacters)
    }
  }
}
