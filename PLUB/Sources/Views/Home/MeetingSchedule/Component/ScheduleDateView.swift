//
//  ScheduleDateView.swift
//  PLUB
//
//  Created by 김수빈 on 2023/02/25.
//

import UIKit

import RxCocoa
import RxSwift

final class ScheduleDateView: UIView {
  
  private let stackView = UIStackView().then {
    $0.spacing = 0
    $0.axis = .vertical
  }
  
  private let monthLabel = UILabel().then {
    $0.font = .caption
    $0.textColor = .black
  }
  
  private let dateLabel = UILabel().then {
    $0.font = .h5
    $0.textColor = .black
  }
  
  init() {
    super.init(frame: .zero)
    setupLayouts()
    setupConstraints()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setupLayouts() {
    addSubview(stackView)
    
    [monthLabel, dateLabel].forEach {
      stackView.addArrangedSubview($0)
    }
  }

  private func setupConstraints() {
    stackView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
    
    monthLabel.snp.makeConstraints {
      $0.height.equalTo(16)
    }
    
    dateLabel.snp.makeConstraints {
      $0.height.equalTo(23)
    }
  }
  
  func setText(_ text: String) {
    monthLabel.text = text
    dateLabel.text = text
  }
}
