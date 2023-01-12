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

class CategoryInfoListView: UIView {
  private let categoryInfoListViewType: CategoryInfoListViewType
  
  private lazy var categoryInfoListStackView = UIStackView(arrangedSubviews: [locationInfoView, peopleInfoView, whenInfoView]).then {
    $0.sizeToFit()
  }
  
  private let locationInfoView = CategoryInfoView(categoryType: .location)
  private let peopleInfoView = CategoryInfoView(categoryType: .people)
  private let whenInfoView = CategoryInfoView(categoryType: .when)
  
  init(categoryInfoListViewType: CategoryInfoListViewType) {
    self.categoryInfoListViewType = categoryInfoListViewType
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
    
    switch categoryInfoListViewType {
    case .vertical:
      categoryInfoListStackView.axis = .vertical
      categoryInfoListStackView.alignment = .top
      categoryInfoListStackView.spacing = 8
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
    $0.spacing = 1
    $0.distribution = .equalSpacing
    $0.axis = .horizontal
  }
  
  private let infoImageView = UIImageView().then {
    $0.contentMode = .scaleAspectFit
  }
  
  private let infoLabel = UILabel().then {
    $0.textColor = .white
    $0.font = .overLine
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
      infoImageView.image = UIImage(named: "location")
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
  
  public func configureUI(with model: String) {
    switch categoryType {
    case .people:
      infoLabel.text = "참여인원 \(model)명"
    default:
      infoLabel.text = model
    }
  }
}
