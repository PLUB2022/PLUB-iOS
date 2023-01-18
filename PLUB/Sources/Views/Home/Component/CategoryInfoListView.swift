//
//  SelectedCategoryInfoView.swift
//  PLUB
//
//  Created by 이건준 on 2022/12/23.
//

import UIKit

struct CategoryInfoListViewModel {
  let location: String
  let peopleCount: Int
  let when: String
}

enum CategoryInfoListViewType {
  case vertical
  case horizontal
}

enum CategoryType {
  case location
  case people
  case when
}

struct CategoryOption: OptionSet {
  let rawValue: UInt
  
  static let location = CategoryOption(rawValue: 1 << 0) // 카테고리 위치
  static let people = CategoryOption(rawValue: 1 << 1) // 카테고리 인원
  static let when = CategoryOption(rawValue: 1 << 2) // 카테고리 시간
  static let all = CategoryOption([.location, .people, .when])
}

class CategoryInfoListView: UIView {
  private let categoryInfoListViewType: CategoryInfoListViewType
  
  private let categoryInfoListStackView = UIStackView().then {
    $0.sizeToFit()
  }
  
  private lazy var locationInfoView = CategoryInfoView(categoryType: .location)
  private lazy var peopleInfoView = CategoryInfoView(categoryType: .people)
  private lazy var whenInfoView = CategoryInfoView(categoryType: .when)
  
  init(categoryInfoListViewType: CategoryInfoListViewType, options: CategoryOption = []) {
    self.categoryInfoListViewType = categoryInfoListViewType
    super.init(frame: .zero)
    configureUI()
    
    if options.contains(.location) {
      categoryInfoListStackView.addArrangedSubview(locationInfoView)
    }
    if options.contains(.people) {
      categoryInfoListStackView.addArrangedSubview(peopleInfoView)
    }
    if options.contains(.when) {
      categoryInfoListStackView.addArrangedSubview(whenInfoView)
    }
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    addSubview(categoryInfoListStackView)
    categoryInfoListStackView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
    
    switch categoryInfoListViewType {
    case .vertical:
      categoryInfoListStackView.axis = .vertical
      categoryInfoListStackView.alignment = .top
      categoryInfoListStackView.spacing = 4
    case .horizontal:
      categoryInfoListStackView.axis = .horizontal
      categoryInfoListStackView.spacing = 8
      categoryInfoListStackView.alignment = .leading
    }
  }
  
  public func configureUI(with model: CategoryInfoListViewModel) {
    locationInfoView.configureUI(with: model.location)
    peopleInfoView.configureUI(with: "\(model.peopleCount)")
    whenInfoView.configureUI(with: model.when)
  }
}

class CategoryInfoView: UIView {
  
  private let categoryType: CategoryType
  
  private lazy var stackView = UIStackView(arrangedSubviews: [infoImageView, infoLabel]).then {
    $0.spacing = 4
    $0.distribution = .equalSpacing
    $0.axis = .horizontal
  }
  
  private let infoImageView = UIImageView().then {
    $0.contentMode = .scaleAspectFit
    $0.sizeToFit()
  }
  
  private let infoLabel = UILabel().then {
    $0.textColor = .white
    $0.font = .overLine
    $0.numberOfLines = 1
    $0.lineBreakMode = .byTruncatingTail
    $0.sizeToFit()
  }
  
  init(categoryType: CategoryType) {
    self.categoryType = categoryType
    super.init(frame: .zero)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    layer.masksToBounds = true
    layer.cornerRadius = 4
    switch categoryType {
    case .location:
      infoImageView.image = UIImage(named: "whiteLocation")
      infoImageView.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
      infoLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    case .when:
      infoImageView.image = UIImage(named: "when")
    case .people:
      infoImageView.image = UIImage(named: "people")
    }
    addSubview(stackView)
    stackView.snp.makeConstraints {
      $0.edges.equalToSuperview()
      $0.height.equalTo(18)
    }
  }
  
  public func configureUI(with model: String, textColor: UIColor = .white) {
    switch categoryType {
    case .people:
      infoLabel.text = "참여인원 \(model)명"
    case .location:
      if textColor == .main {
        infoLabel.textColor = textColor
        infoImageView.image = UIImage(named: "mainLocation")
      }
      infoLabel.text = model
    case .when:
      infoLabel.text = model
    }
  }
}
