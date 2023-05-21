//
//  AnnouncementViewController.swift
//  PLUB
//
//  Created by 홍승현 on 2023/05/16.
//

import UIKit

import SnapKit
import Then

final class AnnouncementViewController: BaseViewController {
  
  // MARK: - Properties
  
  private let viewModel: AnnouncementViewModelType
  
  // MARK: - UI Components
  
  // MARK: Header
  
  private let headerStackView = UIStackView().then {
    $0.alignment = .center
  }
  
  private let gradientLayer = CAGradientLayer().then {
    $0.locations = [0.7]
    $0.colors = [UIColor.background.cgColor, UIColor.background.withAlphaComponent(0).cgColor]
  }
  
  private let titleLabel = UILabel().then {
    $0.text = "공지사항"
    $0.font = .h3
  }
  
  private let uploadButton = UIButton(
    configuration: .plubFilledButton(
      title: "+ 새 글 작성",
      contentInsets: .init(top: 5, leading: 8, bottom: 5, trailing: 8)
    )
  )
  
  // MARK: Body
  
  private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: .init()).then {
    $0.backgroundColor = .background
    $0.showsVerticalScrollIndicator = false
  }
  
  // MARK: - Initializations
  
  init(viewModel: AnnouncementViewModelType) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Life Cycles
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    viewModel.requestFetchingAnnouncement.onNext(Void())
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    var frame = headerStackView.bounds
    frame.size.height += 32
    gradientLayer.frame = frame
  }
  
  // MARK: - Configurations
  
  override func setupLayouts() {
    super.setupLayouts()
    [collectionView, headerStackView].forEach {
      view.addSubview($0)
    }
    
    headerStackView.layer.addSublayer(gradientLayer)
    [titleLabel, uploadButton].forEach {
      headerStackView.addArrangedSubview($0)
    }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    headerStackView.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide)
      $0.directionalHorizontalEdges.equalToSuperview().inset(16)
    }
    
    collectionView.snp.makeConstraints {
      $0.directionalHorizontalEdges.equalToSuperview().inset(16)
      $0.top.equalTo(headerStackView.snp.top)
      $0.bottom.equalTo(view.safeAreaLayoutGuide)
    }
  }
  
  override func setupStyles() {
    super.setupStyles()
    collectionView.collectionViewLayout = createLayouts()
  }
  
  override func bind() {
    super.bind()
    viewModel.setCollectionViewObserver.onNext(collectionView)
    viewModel.setCollectionViewObserver.onCompleted()
  }
  
  private func createLayouts() -> UICollectionViewLayout {
    
    let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(80)))
    let group = NSCollectionLayoutGroup.vertical(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(80)), subitems: [item])
    
    let section = NSCollectionLayoutSection(group: group)
    // top: 헤더뷰의 높이(30) + 헤더뷰와 첫 번째 셀 사이의 거리(32)
    // 이렇게 처리한 이유: collectionView의 top constraint가 헤더뷰의 top과 같기 때문
    section.contentInsets = .init(top: 30 + 32, leading: 0, bottom: 0, trailing: 0)
    section.interGroupSpacing = 8
    
    return UICollectionViewCompositionalLayout(section: section)
  }
}
