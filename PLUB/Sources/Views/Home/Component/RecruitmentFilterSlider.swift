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
  
  private let peopleCountLabel = UILabel().then {
    $0.sizeToFit()
  }
  
  private let countSlider = UISlider().then {
    $0.value = 0
    $0.tintColor = .main
    $0.minimumValue = 4
    $0.maximumValue = 20
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
    [peopleCountLabel, countSlider].forEach { addSubview($0) }
    peopleCountLabel.snp.makeConstraints {
      $0.top.leading.equalToSuperview()
    }
    
    countSlider.snp.makeConstraints {
      $0.top.equalTo(peopleCountLabel.snp.bottom).offset(8)
      $0.leading.trailing.equalToSuperview()
      $0.height.equalTo(28)
    }
  }
  
  private func bind() {
    countSlider.rx.value
      .map { Int($0) }
      .subscribe(onNext: { value in
        print("값 = \(value)")
        self.updateWrittenCharactersLabel(count: value, pointColor: .main)
      })
      .disposed(by: disposeBag)
  }
  
  private func updateWrittenCharactersLabel(
    count: Int,
    pointColor: UIColor
  ) {
    let writtenCharacters = NSAttributedString(
      string: "\(count)명",
      attributes: [.foregroundColor: pointColor]
    )
    
    let totalCharacters = NSAttributedString(
      string: "인원",
      attributes: [.foregroundColor: UIColor.black, .font: UIFont.subtitle!]
    )
    
    peopleCountLabel.attributedText = NSMutableAttributedString(attributedString: totalCharacters).then {
      $0.append(writtenCharacters)
    }
  }
}
