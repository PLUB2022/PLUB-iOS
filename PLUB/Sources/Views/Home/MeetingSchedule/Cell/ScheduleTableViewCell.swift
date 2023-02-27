//
//  ScheduleTableViewCell.swift
//  PLUB
//
//  Created by 김수빈 on 2023/02/24.
//

import UIKit

import SnapKit
import Kingfisher

enum ScheduleCellIndexType {
  case first // 첫 셀
  case middle // 나머지 셀
  case last // 마지막 셀
}

struct ScheduleTableViewCellModel {
  let day: String // 날짜
  let time: String // 시간
  let name: String // 일정 이름
  let location: String? // 장소
  let participants: [String?] // 참여자 목록
  var indexType: ScheduleCellIndexType // 셀 인덱스 타입
  let isPasted: Bool // 지난 일정인지 여부
}

final class ScheduleTableViewCell: UITableViewCell {
  static let identifier = "ScheduleTableViewCell"
  
  // 점
  private let pointImageView = UIImageView().then {
    $0.image = UIImage(named: "pointGray")
    $0.highlightedImage = UIImage(named: "pointBlack")
  }
  
  // 선
  private let lineView = UIView().then {
    $0.backgroundColor = .black
  }
  
  // 날짜
  private let dateView = ScheduleDateView()
  
  // 제목, 시간, 장소
  private let contentStackView = UIStackView().then {
    $0.spacing = 8
    $0.axis = .vertical
  }
  
  private let titleLabel = UILabel().then {
    $0.font = .subtitle
    $0.textColor = .black
  }
  
  private let timeView = ScheduleDetailContentView(type: .time)
  private let locationView = ScheduleDetailContentView(type: .location)
  
  // 참석자
  private let participantStackView = UIStackView().then {
    $0.spacing = -8
    $0.axis = .horizontal
    $0.alignment = .leading
  }
  
  private let moreParticipantView = UIView().then {
    $0.layer.cornerRadius = 12
    $0.layer.borderWidth = 1
    $0.layer.borderColor = UIColor.white.cgColor
    $0.clipsToBounds = true
    $0.backgroundColor = .mediumGray
  }
  
  private let moreParticipantLabel = UILabel().then {
    $0.font = .overLine
    $0.textColor = .black
  }
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setupLayouts()
    setupConstraints()
    setupStyles()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
  }
  
  private func setupLayouts() {
    [lineView, pointImageView, dateView, contentStackView, participantStackView].forEach {
      addSubview($0)
    }
    
    [titleLabel, timeView, locationView].forEach {
      contentStackView.addArrangedSubview($0)
    }
    
    contentStackView.setCustomSpacing(0, after: timeView)
    
    moreParticipantView.addSubview(moreParticipantLabel)
  }
  
  private func setupConstraints() {
    pointImageView.snp.makeConstraints {
      $0.size.equalTo(9)
      $0.top.equalToSuperview().inset(8)
      $0.leading.equalToSuperview().inset(17)
    }
    
    lineView.snp.makeConstraints {
      $0.top.equalToSuperview()
      $0.bottom.equalToSuperview()
      $0.width.equalTo(1)
      $0.centerX.equalTo(pointImageView.snp.centerX)
    }
    
    dateView.snp.makeConstraints {
      $0.top.equalToSuperview().inset(4)
      $0.leading.equalTo(pointImageView.snp.trailing).offset(8)
    }
    
    contentStackView.snp.makeConstraints {
      $0.top.equalToSuperview().inset(3)
      $0.leading.equalTo(dateView.snp.trailing).offset(16)
      $0.bottom.equalToSuperview().inset(24)
    }
    
    titleLabel.snp.makeConstraints {
      $0.height.equalTo(19)
    }
    
    [timeView, locationView].forEach {
      $0.snp.makeConstraints {
        $0.height.equalTo(21)
      }
    }
    
    participantStackView.snp.makeConstraints {
      $0.height.equalTo(25)
      $0.trailing.equalToSuperview().inset(16)
      $0.top.equalToSuperview()
    }
    
    moreParticipantLabel.snp.makeConstraints {
      $0.center.equalToSuperview()
    }
  }
  
  private func setupStyles() {
    backgroundColor = .background
    selectionStyle = .none
  }
  
  func setupData(with data: ScheduleTableViewCellModel) {
    
    switch data.indexType {
    case .first:
      lineView.snp.updateConstraints {
        $0.top.equalToSuperview().inset(8)
        $0.bottom.equalToSuperview()
      }
    case .middle:
      lineView.snp.updateConstraints {
        $0.top.bottom.equalToSuperview()
      }
    case .last:
      lineView.snp.updateConstraints {
        $0.top.equalToSuperview()
        $0.bottom.equalToSuperview().inset(79)
      }
    }
    
    pointImageView.isHighlighted = data.isPasted ? false : true
    
    dateView.setText(data.day, data.isPasted)
    
    titleLabel.text = data.name
    titleLabel.textColor = data.isPasted ? .deepGray : .black
    
    timeView.setText(data.time, data.isPasted)
    
    if let location = data.location {
      locationView.setText(location, data.isPasted)
      locationView.snp.updateConstraints {
        $0.height.equalTo(21)
      }
    } else {
      locationView.setText(nil, data.isPasted)
      locationView.snp.updateConstraints {
        $0.height.equalTo(0)
      }
    }
    
    participantStackView.subviews.forEach {
      $0.removeFromSuperview()
    }
    
    let totalParticipant = data.participants.count
    
    for (index, participant) in data.participants.enumerated() {

      if index == 3, totalParticipant > 4 { // 참석자수 4명 초과 시, (+) 뷰 추가
        moreParticipantLabel.text = "+\(totalParticipant - 3)"
        addParticipantView(moreParticipantView)
        break
      }
      
      guard let url = URL(string: participant ?? "") else { break }
      
      let imageView = UIImageView().then {
        $0.layer.cornerRadius = 12
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.white.cgColor
        $0.clipsToBounds = true
        $0.kf.setImage(with: url)
      }
      
      addParticipantView(imageView)
    }
  }
  
  private func addParticipantView(_ object: UIView) {
    participantStackView.addArrangedSubview(object)
    
    object.snp.makeConstraints {
      $0.size.equalTo(24)
    }
  }
}
