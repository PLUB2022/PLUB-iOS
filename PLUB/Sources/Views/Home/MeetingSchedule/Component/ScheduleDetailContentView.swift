//
//  ScheduleDetailContentView.swift
//  PLUB
//
//  Created by 김수빈 on 2023/02/25.
//

import UIKit

import RxCocoa
import RxSwift

enum ScheduleDetailType: String, CaseIterable {
  case date
  case location
  case time
  
  var imageName: String {
    switch self {
    case .date:
      return "scheduleBlack16"
    case .location:
      return "locationBlack16"
    case .time:
      return "clockBlack16"
    }
  }
}

final class ScheduleDetailContentView: UIView {
  private let scheduleType: ScheduleDetailType
  
  private let stackView = UIStackView().then {
    $0.spacing = 4
    $0.axis = .horizontal
    $0.alignment = .center
  }
  
  private lazy var imageView = UIImageView().then {
    $0.image = UIImage(named: scheduleType.imageName)
  }
  
  private let label = UILabel().then {
    $0.font = .body2
    $0.textColor = .black
  }
  
  init(type: ScheduleDetailType) {
    scheduleType = type
    super.init(frame: .zero)
    setupLayouts()
    setupConstraints()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setupLayouts() {
    addSubview(stackView)
    [imageView, label].forEach {
      stackView.addArrangedSubview($0)
    }
  }

  private func setupConstraints() {
    stackView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
    
    imageView.snp.makeConstraints {
      $0.size.equalTo(16)
    }
    
    label.snp.makeConstraints {
      $0.height.equalTo(21)
    }
  }
  
  func setText(_ text: String) {
    label.text = text
  }
}
