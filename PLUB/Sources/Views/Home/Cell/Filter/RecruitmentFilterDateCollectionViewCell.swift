//
//  RecruitmentFilterDateCollectionViewCell.swift
//  PLUB
//
//  Created by 이건준 on 2023/04/09.
//

import UIKit

import SnapKit
import Then

struct RecruitmentFilterDateCollectionViewCellModel {
  let day: Day
  var isTapped: Bool
  
  init(day: Day) {
    self.day = day
    isTapped = false
  }
  
  init(day: Day, isTapped: Bool) {
    self.day = day
    self.isTapped = isTapped
  }
  
  mutating func tappedDay() -> Bool {
    isTapped.toggle()
    return isTapped
  }
}

final class RecruitmentFilterDateCollectionViewCell: UICollectionViewCell {
  static let identifier = "RecruitmentFilterDateCollectionViewCell"
  
  var isTapped: Bool = false {
    didSet {
      contentView.backgroundColor = isTapped ? .main : .white
      dayLabel.textColor = isTapped ? .white : .deepGray
      contentView.layer.borderColor = isTapped ? UIColor.main.cgColor : UIColor.deepGray.cgColor
    }
  }
  
  private let dayLabel = UILabel().then {
    $0.textColor = .deepGray
    $0.font = .caption
    $0.textAlignment = .center
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    contentView.layer.borderWidth = 1
    contentView.layer.borderColor = UIColor.deepGray.cgColor
    contentView.layer.cornerRadius = 8
    contentView.layer.masksToBounds = true
    contentView.backgroundColor = .white
    
    contentView.addSubview(dayLabel)
    dayLabel.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
  }
  
  func configureUI(with model: String) {
    dayLabel.text = model
  }
  
  func configureUI(with model: RecruitmentFilterDateCollectionViewCellModel) {
    dayLabel.text = model.day == .all ? model.day.kor : "\(model.day.kor)요일"
    isTapped = model.isTapped
  }
}
