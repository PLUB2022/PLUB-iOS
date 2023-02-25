//
//  ClipboardViewController.swift
//  PLUB
//
//  Created by 이건준 on 2023/02/20.
//

import UIKit

import RxSwift
import RxCocoa
import SnapKit
import Then

final class ClipboardViewController: BaseViewController {
  
  // MARK: - UI Components
  
  private let pinImageView = UIImageView(image: .init(named: "pin"))
  
  private let titleLabel = UILabel().then {
    $0.text = "클립보드"
    $0.font = .h3
  }
  
  private let titleStackView = UIStackView().then {
    $0.alignment = .center
    $0.spacing = 8
  }
  
  private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).then {
    $0.backgroundColor = .background
  }
  
  private let wholeStackView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 16
    
  }
  
  // MARK: - Properties
  
  private let viewModel: ClipboardViewModelType
  
  
  // MARK: - Initializations
  
  init(viewModel: ClipboardViewModelType) {
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
  
  // MARK: - Configuration
  
  override func setupLayouts() {
    super.setupLayouts()
    view.addSubview(wholeStackView)
    titleStackView.addArrangedSubview(pinImageView)
    titleStackView.addArrangedSubview(titleLabel)
    wholeStackView.addArrangedSubview(titleStackView)
    wholeStackView.addArrangedSubview(collectionView)
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    wholeStackView.snp.makeConstraints {
      $0.directionalVerticalEdges.equalTo(view.safeAreaLayoutGuide)
      $0.directionalHorizontalEdges.equalToSuperview().inset(Metric.collectionViewLeftRight)
    }
    
    pinImageView.snp.makeConstraints {
      $0.size.equalTo(24)
    }
  }
  
  override func setupStyles() {
    super.setupStyles()
  }
  
  override func bind() {
    super.bind()
  }
}

extension ClipboardViewController {
  private enum Metric {
    static let collectionViewLeftRight = 16
  }
}
