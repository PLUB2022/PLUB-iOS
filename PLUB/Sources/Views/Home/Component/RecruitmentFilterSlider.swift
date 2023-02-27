//
//  RecruitmentFilterSlider.swift
//  PLUB
//
//  Created by 이건준 on 2023/02/12.
//

import UIKit

import RxSwift
import RxCocoa
import SnapKit
import Then

class RecruitmentFilterSlider: UIView {
  
  private let disposeBag = DisposeBag()
  
  var accountNum: Int = 4 {
    didSet {
      updateWrittenCharactersLabel(count: accountNum, pointColor: .main)
    }
  }
  
  private let peopleCountLabel = UILabel().then {
    $0.sizeToFit()
  }
  
  private let countSlider = UISlider().then {
    $0.value = 0
    $0.tintColor = .main
    $0.minimumValue = 4
    $0.maximumValue = 20
  }
  
  private let minCountLabel = UILabel().then {
    $0.textColor = .black
    $0.text = "4명"
    $0.font = .caption
  }
  
  private let maxCountLabel = UILabel().then {
    $0.textColor = .black
    $0.text = "20명"
    $0.font = .caption
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
    [peopleCountLabel, countSlider, minCountLabel, maxCountLabel].forEach { addSubview($0) }
    peopleCountLabel.snp.makeConstraints {
      $0.top.leading.equalToSuperview()
    }
    
    countSlider.snp.makeConstraints {
      $0.top.equalTo(peopleCountLabel.snp.bottom).offset(8)
      $0.leading.trailing.equalToSuperview()
      $0.height.equalTo(28)
    }
    
    minCountLabel.snp.makeConstraints {
      $0.top.equalTo(countSlider.snp.bottom)
      $0.leading.equalToSuperview()
    }
    
    maxCountLabel.snp.makeConstraints {
      $0.top.equalTo(countSlider.snp.bottom)
      $0.trailing.equalToSuperview()
    }
  }
  
  private func bind() {
    countSlider.rx.value
      .map { Int($0) }
      .subscribe(with: self, onNext: { owner, value in
        owner.accountNum = value
      })
      .disposed(by: disposeBag)
  }
  
  private func updateWrittenCharactersLabel(
    count: Int,
    pointColor: UIColor
  ) {
    let countCharacters = NSAttributedString(
      string: "\(count)명",
      attributes: [.foregroundColor: pointColor]
    )
    
    let totalCharacters = NSAttributedString(
      string: "인원 ",
      attributes: [.foregroundColor: UIColor.black, .font: UIFont.subtitle!]
    )
    
    peopleCountLabel.attributedText = NSMutableAttributedString(attributedString: totalCharacters).then {
      $0.append(countCharacters)
    }
  }
}
