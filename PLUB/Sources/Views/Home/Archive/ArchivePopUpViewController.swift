//
//  ArchivePopUpViewController.swift
//  PLUB
//
//  Created by 홍승현 on 2023/04/14.
//

import UIKit

import RxSwift
import RxCocoa
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
    $0.register(ArchiveDetailColletionViewCell.self, forCellWithReuseIdentifier: ArchiveDetailColletionViewCell.identifier)
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
  }
  
  override func bind() {
    super.bind()
    
    // viewDidLoad 이후 API 요청을 위한 값 emit
    viewModel.viewDidLoadObserver.onNext(Void())
    
    let archives = viewModel.fetchArchives.share()
    
    // fetching된 아카이브 모델값으로 view 업데이트
    archives
      .subscribe(with: self) { owner, content in
        owner.configure(with: content)
      }
      .disposed(by: disposeBag)
    
    // 아카이브에 존재하는 이미지 배열을 갖고, collectionView에 바인딩, 아카이브 image 업데이트
    archives
      .map(\.images)
      .bind(to: collectionView.rx.items(
        cellIdentifier: ArchiveDetailColletionViewCell.identifier,
        cellType: ArchiveDetailColletionViewCell.self
      )) { _, imageString, cell in
        cell.configure(with: imageString)
      }
      .disposed(by: disposeBag)
    
    closeButton.rx.tap
      .subscribe(with: self) { owner, _ in
        owner.dismiss(animated: true)
      }
      .disposed(by: disposeBag)
  }
  
  private func configure(with model: ArchiveContent) {
    guard let date = DateFormatterFactory.dateWithHypen.date(from: model.postDate) else { return }
    orderLabel.text = "\(model.sequence)번째 기록"
    dateLabel.text = DateFormatterFactory.dateWithDot.string(from: date)
    titleLabel.text = model.title
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

private extension ArchivePopUpViewController {
  enum Metrics {
    enum Padding {
      static let horizontal: CGFloat = 16
    }
  }
}
