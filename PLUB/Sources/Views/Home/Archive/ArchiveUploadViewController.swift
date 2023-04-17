// 
//  ArchiveUploadViewController.swift
//  PLUB
//
//  Created by 홍승현 on 2023/04/17.
//

import UIKit

import RxSwift
import RxCocoa
import SnapKit
import Then

final class ArchiveUploadViewController: BaseViewController {
  
  // MARK: - Properties
  
  private let viewModel: ArchiveUploadViewModelType
  
  // MARK: - UI Components
  
  private let archiveTitleLabelContainerView = UIView()
  
  private let archiveTitleLabel = UILabel().then {
    $0.text = "아카이브 업로드"
    $0.textColor = .black
    $0.font = .h3
  }
  
  private let gradientLayer = CAGradientLayer().then {
    $0.locations = [0.7]
    $0.colors = [UIColor.background.cgColor, UIColor.background.withAlphaComponent(0).cgColor]
  }
  
  private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: .init()).then {
    $0.register(
      ArchiveUploadCollectionViewCell.self,
      forCellWithReuseIdentifier: ArchiveUploadCollectionViewCell.identifier
    )
    $0.register(
      ArchiveUploadHeaderView.self,
      forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
      withReuseIdentifier: ArchiveUploadHeaderView.identifier
    )
    $0.backgroundColor = .background
    $0.showsVerticalScrollIndicator = false
  }
  
  private let completeButton = UIButton(configuration: .plain()).then {
    $0.configurationUpdateHandler = $0.configuration?.plubButton(label: "완료")
    $0.isEnabled = false
  }
  
  // MARK: - Initializations
  
  init(viewModel: ArchiveUploadViewModelType) {
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
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    var frame = archiveTitleLabelContainerView.bounds
    frame.size.height += 32
    gradientLayer.frame = frame
  }
  
  // MARK: - Configuration
  
  override func setupLayouts() {
    super.setupLayouts()
    [collectionView, archiveTitleLabelContainerView, completeButton].forEach {
      view.addSubview($0)
    }
    archiveTitleLabelContainerView.layer.addSublayer(gradientLayer)
    archiveTitleLabelContainerView.addSubview(archiveTitleLabel)
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    archiveTitleLabelContainerView.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide).inset(14)
      $0.directionalHorizontalEdges.equalToSuperview().inset(Margin.horizontal)
    }
    
    archiveTitleLabel.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
    
    collectionView.snp.makeConstraints {
      $0.directionalHorizontalEdges.equalToSuperview().inset(Margin.horizontal)
      $0.top.equalTo(archiveTitleLabel.snp.bottom)
      $0.bottom.equalTo(completeButton.snp.top)
    }
    
    completeButton.snp.makeConstraints {
      $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
      $0.directionalHorizontalEdges.equalToSuperview().inset(Margin.horizontal)
      $0.height.equalTo(Size.buttonHeight)
    }
  }
  
  override func setupStyles() {
    super.setupStyles()
    collectionView.collectionViewLayout = createLayouts()
  }
  
  override func bind() {
    super.bind()
  }
}

// MARK: - UICollectionViewCompositionalLayout

private extension ArchiveUploadViewController {
  func createLayouts() -> UICollectionViewLayout {
    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalWidth(0.5))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    
    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100))
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 2)
    group.interItemSpacing = .fixed(12)
    
    let section = NSCollectionLayoutSection(group: group)
    section.interGroupSpacing = 12
    section.contentInsets = .init(top: 8, leading: 0, bottom: 32, trailing: 0)
    
    let headerItem = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(124)), elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
    section.boundarySupplementaryItems = [headerItem]
    
    
    return UICollectionViewCompositionalLayout(section: section)
  }
}

// MARK: - Constants

private extension ArchiveUploadViewController {
  
  enum Margin {
    static let horizontal = 16
  }
  
  enum Size {
    static let buttonHeight = 46
  }
}
