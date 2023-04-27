// 
//  NotificationViewController.swift
//  PLUB
//
//  Created by 홍승현 on 2023/04/24.
//

import UIKit

import RxSwift
import RxCocoa
import SnapKit
import Then

final class NotificationViewController: BaseViewController {
  
  // MARK: - Properties
  
  private let viewModel: NotificationViewModelType
  
  // MARK: - UI Components
  
  private let titleView = UILabel().then {
    $0.text = "알림"
    $0.textColor = .black
    $0.font = .h3
  }
  
  private let titleUnderlineView = UIView().then {
    $0.backgroundColor = .main
  }
  
  private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: .init()).then {
    var configuration = UICollectionLayoutListConfiguration(appearance: .plain)
    configuration.showsSeparators = false
    configuration.backgroundColor = .background
    $0.collectionViewLayout = UICollectionViewCompositionalLayout.list(using: configuration)
    $0.backgroundColor = .background
    $0.contentInset = .init(top: 24, left: 0, bottom: 0, right: 0)
  }
  
  private let filterButton = UIButton(configuration: .plubFilterButton(title: "전체"))
  
  // MARK: - Initializations
  
  init(viewModel: NotificationViewModelType) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Life Cycles
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.isNavigationBarHidden = true
  }
  
  // MARK: - Configuration
  
  override func setupLayouts() {
    super.setupLayouts()
    [titleView, titleUnderlineView, filterButton, collectionView].forEach {
      view.addSubview($0)
    }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    titleView.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide).inset(20)
      $0.leading.equalToSuperview().inset(Margin.horizontal)
    }
    
    titleUnderlineView.snp.makeConstraints {
      $0.top.equalTo(titleView.snp.bottom).offset(4)
      $0.height.equalTo(3)
      $0.directionalHorizontalEdges.equalTo(titleView).inset(-4)
    }
    
    filterButton.snp.makeConstraints {
      $0.centerY.equalTo(titleView).offset(2)
      $0.trailing.equalToSuperview().inset(Margin.horizontal)
    }
    
    collectionView.snp.makeConstraints {
      $0.directionalHorizontalEdges.equalToSuperview()
      $0.top.equalTo(titleUnderlineView.snp.bottom)
      $0.bottom.equalTo(view.safeAreaLayoutGuide)
    }
    
  }
  
  override func setupStyles() {
    super.setupStyles()
  }
  
  override func bind() {
    super.bind()
  }
}

// MARK: - Constants

private extension NotificationViewController {
  enum Margin {
    static let horizontal = 16
  }
}

