//
//  LocationBottomSheetViewController.swift
//  PLUB
//
//  Created by 김수빈 on 2023/01/21.
//

import UIKit

protocol LocationBottomSheetDelegate: AnyObject {
  func selectImage(image: UIImage)
}

final class LocationBottomSheetViewController: BottomSheetViewController {
  weak var delegate: LocationBottomSheetDelegate?
  
  private let titleLabel = UILabel().then {
    $0.text = "장소 검색"
    $0.textColor = .black
    $0.font = .h5
  }
  
  private let searchView = SearchView()
  
  private let searchCountLabel = UILabel().then {
    $0.text = "검색결과 20개"
    $0.textColor = .black
    $0.font = .body2
  }

  private let noneView = NoLocationView()
  
  private let tableView = UITableView().then {
    $0.backgroundColor = .clear
    $0.isHidden = true
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    [titleLabel, searchView, searchCountLabel, noneView, tableView].forEach {
      contentView.addSubview($0)
    }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    contentView.snp.remakeConstraints {
      $0.leading.trailing.bottom.equalToSuperview()
      $0.height.equalTo(639)
    }
    
    titleLabel.snp.makeConstraints {
      $0.top.equalToSuperview().inset(16)
      $0.height.equalTo(23)
      $0.centerX.equalToSuperview()
    }
    
    searchView.snp.makeConstraints {
      $0.top.equalTo(titleLabel.snp.bottom).offset(24)
      $0.leading.trailing.equalToSuperview().inset(24)
      $0.height.equalTo(40)
    }
    
    searchCountLabel.snp.makeConstraints {
      $0.top.equalTo(searchView.snp.bottom).offset(8)
      $0.trailing.equalToSuperview().inset(24)
      $0.height.equalTo(21)
    }
    
    noneView.snp.makeConstraints {
      $0.top.equalTo(searchView.snp.bottom).offset(64)
      $0.centerX.equalToSuperview()
      $0.leading.trailing.equalToSuperview()
      $0.height.equalTo(175)
    }
    
    tableView.snp.makeConstraints {
      $0.top.equalTo(searchCountLabel.snp.bottom).offset(8)
      $0.leading.trailing.equalToSuperview().inset(24)
      $0.bottom.equalToSuperview()
    }
  }
  
  override func bind() {
    super.bind()

  }
}
