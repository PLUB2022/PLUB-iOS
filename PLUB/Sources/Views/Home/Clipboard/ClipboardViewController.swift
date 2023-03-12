//
//  ClipboardViewController.swift
//  PLUB
//
//  Created by 홍승현 on 2023/02/24.
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
    $0.showsVerticalScrollIndicator = false
    $0.register(BoardCollectionViewCell.self, forCellWithReuseIdentifier: BoardCollectionViewCell.identifier)
    $0.backgroundColor = .background
  }
  
  private let wholeStackView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 16
    
  }
  
  // MARK: - Properties
  
  private let viewModel: ClipboardViewModelType & ClipboardCellDataStore
  
  
  // MARK: - Initializations
  
  init(viewModel: ClipboardViewModelType & ClipboardCellDataStore) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Life Cycles
  
  override func viewDidLoad() {
    super.viewDidLoad()
    collectionView.delegate = self
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
      $0.directionalHorizontalEdges.equalToSuperview().inset(Metric.wholeStackViewLeftRight)
    }
    
    pinImageView.snp.makeConstraints {
      $0.size.equalTo(Metric.pinImageViewSize)
    }
  }
  
  override func setupStyles() {
    super.setupStyles()
  }
  
  override func bind() {
    super.bind()
    viewModel.fetchClipboards
      .drive(collectionView.rx.items(cellIdentifier: BoardCollectionViewCell.identifier, cellType: BoardCollectionViewCell.self)) { index, model, cell in
        cell.configure(with: model.toBoardModel)
      }
      .disposed(by: disposeBag)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension ClipboardViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    // TODO: 승현 - Clipboard API 연동해서 높이 설정
    // 너비 양옆 inset 16을 제외, 높이 305 고정 (photo)
    // 너비 양옆 inset 16을 제외, 높이 114 고정 (photoAndText, text)
    return .init(width: view.bounds.width - 16 * 2, height: 305)
  }
}

// MARK: - Constants

extension ClipboardViewController {
  private enum Metric {
    static let wholeStackViewLeftRight = 16
    static let pinImageViewSize = 24
  }
}
