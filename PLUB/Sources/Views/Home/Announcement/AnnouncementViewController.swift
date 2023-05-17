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
    $0.collectionViewLayout = UICollectionViewCompositionalLayout.list(using: .init(appearance: .insetGrouped))
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
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    var frame = headerStackView.bounds
    frame.size.height += 32
    gradientLayer.frame = frame
  }
  
  // MARK: - Configurations
  
  override func setupLayouts() {
    super.setupLayouts()
    view.addSubview(collectionView)
    view.addSubview(headerStackView)
    
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
  
  override func bind() {
    super.bind()
    viewModel.setCollectionViewObserver.onNext(collectionView)
    viewModel.setCollectionViewObserver.onCompleted()
  }
}
