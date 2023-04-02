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
  
  private let grabber = UIView().then {
    $0.backgroundColor = .mediumGray
  }
  
  private lazy var bottomSheetView = PhotoBottomSheetListView(
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
    [grabber, bottomSheetView].forEach { contentView.addSubview($0) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    grabber.snp.makeConstraints {
      $0.width.equalTo(48)
      $0.height.equalTo(4)
      $0.centerX.equalToSuperview()
      $0.top.equalToSuperview().inset(8)
    }
    
    bottomSheetView.snp.makeConstraints {
      $0.top.equalTo(grabber.snp.bottom).offset(24)
      $0.directionalHorizontalEdges.equalToSuperview().inset(16)
      $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(24)
    }
  }
}
