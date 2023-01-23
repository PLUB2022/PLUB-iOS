//
//  SelectedCategoryInfoView.swift
//  PLUB
//
//  Created by 이건준 on 2022/12/23.
//

import UIKit

struct CategoryInfoListModel {
  let location: String
  let peopleCount: Int
  let when: String
}

enum CategoryAlignment {
  case vertical
  case horizontal
}

enum CategoryType {
  case location
  case people
  case when
}

enum CategoryListType {
  case noLocation
  case onlyLocation
  case all
}

class CategoryInfoListView: UIView {
  private let categoryAlignment: CategoryAlignment
  private let categoryListType: CategoryListType
  
  private let categoryInfoListStackView = UIStackView().then {
    $0.sizeToFit()
  }
  
  private lazy var locationInfoView = CategoryInfoView(categoryType: .location)
  private lazy var peopleInfoView = CategoryInfoView(categoryType: .people)
  private lazy var whenInfoView = CategoryInfoView(categoryType: .when)
  
  init(categoryAlignment: CategoryAlignment, categoryListType: CategoryListType) {
    self.categoryAlignment = categoryAlignment
    self.categoryListType = categoryListType
    super.init(frame: .zero)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    addSubview(categoryInfoListStackView)
    categoryInfoListStackView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
    
    switch categoryAlignment {
    case .vertical:
      categoryInfoListStackView.axis = .vertical
      categoryInfoListStackView.alignment = .top
      categoryInfoListStackView.spacing = 4
    case .horizontal:
      categoryInfoListStackView.axis = .horizontal
      categoryInfoListStackView.spacing = 8
      categoryInfoListStackView.alignment = .leading
    }
    
    switch categoryListType {
    case .noLocation:
      categoryInfoListStackView.addArrangedSubview(peopleInfoView)
      categoryInfoListStackView.addArrangedSubview(whenInfoView)
    case .onlyLocation:
      categoryInfoListStackView.addArrangedSubview(locationInfoView)
    case .all:
      categoryInfoListStackView.addArrangedSubview(locationInfoView)
      categoryInfoListStackView.addArrangedSubview(peopleInfoView)
      categoryInfoListStackView.addArrangedSubview(whenInfoView)
    }
  }
  
  public func configureUI(with model: CategoryInfoListModel) {
    locationInfoView.configureUI(with: model.location, categoryListType: categoryListType)
    peopleInfoView.configureUI(with: "\(model.peopleCount)", categoryListType: categoryListType)
    whenInfoView.configureUI(with: model.when, categoryListType: categoryListType)
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
      infoImageView.image = UIImage(named: "whiteWhen")
    case .people:
      infoImageView.image = UIImage(named: "whitePeople")
    }
    addSubview(stackView)
    stackView.snp.makeConstraints {
      $0.edges.equalToSuperview()
      $0.height.equalTo(18)
    }
  }
  
  public func configureUI(with model: String, categoryListType: CategoryListType) {
    switch categoryType {
    case .location:
      infoLabel.text = model
    case .people:
      infoLabel.text = "모집 인원 \(model)명"
    case .when:
      infoLabel.text = model
    }
    
    switch categoryListType {
    case .noLocation:
      infoLabel.textColor = .black
      if categoryType == .people {
        infoImageView.image = UIImage(named: "blackPeople")
      } else if categoryType == .when {
        infoImageView.image = UIImage(named: "blackWhen")
      }
    case .onlyLocation:
      infoLabel.textColor = .main
      infoImageView.image = UIImage(named: "mainLocation")
    case .all:
      infoLabel.textColor = .white
    }
  }
}
