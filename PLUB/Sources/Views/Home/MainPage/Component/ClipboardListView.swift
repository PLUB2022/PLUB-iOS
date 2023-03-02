////
////  ClipboardListView.swift
////  PLUB
////
////  Created by 이건준 on 2023/03/03.
////
//
//import UIKit
//
//import SnapKit
//import Then
//
//class ClipboardListView: UIView {
//
//  private let clipboardListType: ClipboardListType
//  private let clipboardTypes: [ClipboardType]
//
//  private let horizontalStackView = UIStackView().then {
//    $0.axis = .horizontal
//    $0.distribution = .fillEqually
//  }
//
//  private let verticalStackView = UIStackView().then {
//    $0.axis = .vertical
//    $0.distribution = .fillEqually
//  }
//
//  private let boardContentLabel = UILabel()
//
//  private let boardImageView = UIImageView()
//
//  init(clipboardListType: ClipboardListType, clipboardTypes: [ClipboardType]) {
//    self.clipboardListType = clipboardListType
//    self.clipboardTypes = clipboardTypes
//    super.init(frame: .zero)
//    configureUI()
//  }
//
//  required init?(coder: NSCoder) {
//    fatalError("init(coder:) has not been implemented")
//  }
//
//  private func configureUI() {
//    addSubview(horizontalStackView)
//    horizontalStackView.snp.makeConstraints {
//      $0.directionalEdges.equalToSuperview()
//    }
//    switch clipboardListType {
//    case .one:
//      let clipboardType = clipboardTypes.first
//      switch clipboardType {
//      case .onlyText:
//        horizontalStackView.addArrangedSubview(boardContentLabel)
//      case .image:
//        horizontalStackView.addArrangedSubview(boardImageView)
//      case .none:
//        break
//      }
//    case .two:
//
//    case .moreThanThree:
//      <#code#>
//    }
//  }
//}
