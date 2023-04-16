//
//  ArchivePopUpViewController.swift
//  PLUB
//
//  Created by 홍승현 on 2023/04/14.
//

import UIKit

import SnapKit
import Then

final class ArchivePopUpViewController: BaseViewController {
  
  private let viewModel: ArchivePopUpViewModelType
  
  // MARK: - UI Components
  
  /// 모달 뷰
  private let containerView = UIView().then {
    $0.backgroundColor = .white
    $0.layer.cornerRadius = 20
  }
  
  /// 닫기 버튼
  private let closeButton = UIButton().then {
    $0.setImage(.init(named: "xMarkDeepGray"), for: .normal)
  }
  
  private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: .init()).then {
    $0.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "UICollectionViewCell")
    $0.alwaysBounceVertical = false
  }
  
  private let orderLabel = UILabel().then {
    $0.text = "번째 기록"
    $0.textColor = .black
    $0.font = .h5
  }
  
  private let dateLabel = UILabel().then {
    $0.text = "2022.03.25"
    $0.textColor = .mediumGray
    $0.font = .body2
  }
  
  private let titleLabel = UILabel().then {
    $0.text = "아카이브 제목"
    $0.numberOfLines = 0
    $0.textColor = .black
    $0.font = .h2
  }
  
  // MARK: - Initializations
  
  init(viewModel: ArchivePopUpViewModelType) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
    
    // popup motion 적용
    modalTransitionStyle = .crossDissolve
    modalPresentationStyle = .overFullScreen
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Configurations
  
  override func setupLayouts() {
    super.setupLayouts()
    
    view.addSubview(containerView)
    
    [closeButton, collectionView, orderLabel, dateLabel, titleLabel].forEach {
      containerView.addSubview($0)
    }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    containerView.snp.makeConstraints {
      $0.directionalHorizontalEdges.equalToSuperview().inset(24)
      $0.center.equalToSuperview()
    }
    
    closeButton.snp.makeConstraints {
      $0.top.trailing.equalToSuperview().inset(7)
      $0.size.equalTo(32)
    }
    
    collectionView.snp.makeConstraints {
      $0.top.equalToSuperview().inset(50)
      $0.directionalHorizontalEdges.equalToSuperview()
      $0.height.equalTo(collectionView.snp.width).offset(-Metrics.Padding.horizontal * 2)
    }
    
    orderLabel.snp.makeConstraints {
      $0.leading.equalToSuperview().inset(Metrics.Padding.horizontal)
      $0.top.equalTo(collectionView.snp.bottom).offset(20)
    }
    
    dateLabel.snp.makeConstraints {
      $0.bottom.equalTo(orderLabel.snp.bottom)
      $0.leading.equalTo(orderLabel.snp.trailing).offset(10)
    }
    
    titleLabel.snp.makeConstraints {
      $0.directionalHorizontalEdges.equalToSuperview().inset(Metrics.Padding.horizontal)
      $0.top.equalTo(orderLabel.snp.bottom).offset(10)
      $0.bottom.equalToSuperview().inset(30)
    }
  }
  
  override func setupStyles() {
    super.setupStyles()
    view.backgroundColor = .black.withAlphaComponent(0.45)
    collectionView.collectionViewLayout = createLayouts()
    collectionView.dataSource = self
  }
  
  override func bind() {
    super.bind()
    
    closeButton.rx.tap
      .subscribe(with: self) { owner, _ in
        owner.dismiss(animated: true)
      }
      .disposed(by: disposeBag)
  }
}

// MARK: - CompositionalLayout

extension ArchivePopUpViewController {
  /// 아카이빙된 이미지를 셀로부터 보여주기 위한 컬렉션 뷰 레이아웃을 생성합니다.
  private func createLayouts() -> UICollectionViewLayout {
    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    
    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9), heightDimension: .fractionalHeight(1.0))
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
    group.interItemSpacing = .fixed(8)
    
    let section = NSCollectionLayoutSection(group: group)
    section.interGroupSpacing = 8
    section.orthogonalScrollingBehavior = .groupPaging
    section.contentInsets = NSDirectionalEdgeInsets(
      top: 0,
      leading: Metrics.Padding.horizontal,
      bottom: 0,
      trailing: Metrics.Padding.horizontal
    )
    
    let layout = UICollectionViewCompositionalLayout(section: section)
    return layout
  }
}

// MARK: - UICollectionViewDataSource

extension ArchivePopUpViewController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return 10
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UICollectionViewCell", for: indexPath)
    cell.contentView.backgroundColor = .deepGray
    cell.contentView.layer.cornerRadius = 10
    return cell
  }
}

private extension ArchivePopUpViewController {
  enum Metrics {
    enum Padding {
      static let horizontal: CGFloat = 16
    }
  }
}
