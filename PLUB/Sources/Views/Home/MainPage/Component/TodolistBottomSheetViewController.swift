//
//  TodolistBottomSheetViewController.swift
//  PLUB
//
//  Created by 이건준 on 2023/03/29.
//

import UIKit

import SnapKit
import Then

enum TodolistBottomSheetType {
  case todoPlanner // 투두리스트 작성자일때
  case report // 투두리스트 작성자아닐때
  
  var text: String {
    switch self {
    case .todoPlanner:
      return "TO-DO 플래너"
    case .report:
      return "신고"
    }
  }
  
  var image: String {
    switch self {
    case .todoPlanner:
      return "editBlack"
    case .report:
      return "lightBeaconMain"
    }
  }
}

final class TodolistBottomSheetViewController: BottomSheetViewController {
  
  private let type: TodolistBottomSheetType
  
  private lazy var bottomSheetView = BottomSheetListView(
    text: type.text,
    image: type.image
  )
  
  init(type: TodolistBottomSheetType) {
    self.type = type
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    contentView.addSubview(bottomSheetView)
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    bottomSheetView.snp.makeConstraints {
      $0.top.equalToSuperview().inset(Metrics.Margin.top)
      $0.directionalHorizontalEdges.bottom.equalToSuperview().inset(Metrics.Margin.horizontal)
      $0.height.equalTo(Metrics.Size.height)
    }
  }
}
