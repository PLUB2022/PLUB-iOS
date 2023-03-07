//
//  BoardViewController.swift
//  PLUB
//
//  Created by 이건준 on 2023/03/02.
//

import UIKit

import SnapKit
import Then

enum BoardViewType: CaseIterable { // 게시판관련 섹션타입
  case clipboard // 최상단 클립보드
  case normalSystem // ViewType이 Normal, System에 해당
}

protocol BoardViewControllerDelegate: AnyObject {
  func calculateHeight(_ height: CGFloat)
}

final class BoardViewController: BaseViewController {
  
  weak var delegate: BoardViewControllerDelegate?
  
  private let viewModel: BoardViewModelType
  
  private var clipboardModel: [MockModel] = [] {
    didSet {
      collectionView.reloadSections([0])
    }
  }
  
  /// 스크롤 영역에 따른 헤더 뷰 높이변경을 위한 프로퍼티
  private let min: CGFloat = Device.navigationBarHeight
  private let max: CGFloat = 292
  
  private var type: BoardCollectionHeaderViewType = .clipboard {
    didSet {
      collectionView.reloadSections([0])
    }
  }
  
  private lazy var collectionView = UICollectionView(
    frame: .zero,
    collectionViewLayout: UICollectionViewCompositionalLayout { [weak self] sec, env -> NSCollectionLayoutSection? in
      guard let self = self else { return nil }
      return self.createCollectionViewSection(viewType: BoardViewType.allCases[sec])
    }
  ).then {
    $0.backgroundColor = .background
    $0.register(BoardCollectionViewCell.self, forCellWithReuseIdentifier: BoardCollectionViewCell.identifier)
    $0.register(ClipboardCollectionViewCell.self, forCellWithReuseIdentifier: ClipboardCollectionViewCell.identifier)
    $0.register(BoardCollectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: BoardCollectionHeaderView.identifier)
    $0.delegate = self
    $0.dataSource = self
    $0.bounces = false
  }
  
  init(viewModel: BoardViewModelType = BoardViewModel()) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func setupStyles() {
    super.setupStyles()
//    var configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
//    configuration.backgroundColor = .background
//    configuration.showsSeparators = false
//    let layout = UICollectionViewCompositionalLayout.list(using: configuration)
//    collectionView.collectionViewLayout = layout
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    view.addSubview(collectionView)
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    collectionView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
  }
  
  override func bind() {
    super.bind()
    viewModel.createMockData()
      .subscribe(rx.clipboardModel)
      .disposed(by: disposeBag)
  }
  
  private func createCollectionViewSection(viewType: BoardViewType) -> NSCollectionLayoutSection? {
    switch viewType {
    case .clipboard:
      switch type {
      case .clipboard:
        let horizontalItem = NSCollectionLayoutItem(
          layoutSize: NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1/2),
            heightDimension: .fractionalHeight(1)
          )
        )
        horizontalItem.contentInsets = .init(top: .zero, leading: .zero, bottom: .zero, trailing: 11.87)
        
        let verticalItem = NSCollectionLayoutItem(
          layoutSize: NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(1)
          ))
        
        let verticalGroup = NSCollectionLayoutGroup.vertical(
          layoutSize: NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1/2),
            heightDimension: .fractionalHeight(1)
          ),
          subitem: verticalItem,
          count: 2
        )
        verticalGroup.interItemSpacing = .fixed(9)
        
        let horizontalGroup = NSCollectionLayoutGroup.horizontal(
          layoutSize: NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .absolute(260)
          ), subitems: [
            horizontalItem,
            verticalGroup
          ]
        )
        
        let section = NSCollectionLayoutSection(group: horizontalGroup)
        section.orthogonalScrollingBehavior = .none
        section.contentInsets = .init(top: 16, leading: 16, bottom: .zero, trailing: 16)
        return section
        
      case .noClipboard:
        return nil
      }
      
    case .normalSystem:
      let item = NSCollectionLayoutItem(
        layoutSize: NSCollectionLayoutSize(
          widthDimension: .fractionalWidth(1),
          heightDimension: .fractionalHeight(1)
        )
      )
      
      let group = NSCollectionLayoutGroup.horizontal(
        layoutSize: NSCollectionLayoutSize(
          widthDimension: .fractionalWidth(1),
          heightDimension: .absolute(107)),
        subitems: [item]
      )
      
      let section = NSCollectionLayoutSection(group: group)
      section.orthogonalScrollingBehavior = .none
      section.contentInsets = .init(top: 16, leading: 16, bottom: 16, trailing: 16)
      section.interGroupSpacing = 8
      return section
    }
  }
}

extension BoardViewController: UIScrollViewDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let scroll = scrollView.contentOffset.y
    
    let heightTemp = max - scroll
    
    if heightTemp > max {
      delegate?.calculateHeight(max)
    } else if heightTemp < min {
      delegate?.calculateHeight(min)
    } else {
      delegate?.calculateHeight(heightTemp)
    }
  }
}

extension BoardViewController: UICollectionViewDelegate, UICollectionViewDataSource {
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    switch type {
    case .clipboard:
      return BoardViewType.allCases.count
    case .noClipboard:
      return BoardViewType.allCases.count - 1
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    let section = BoardViewType.allCases[section]
    
    switch section {
    case .clipboard:
      switch type {
      case .clipboard:
        return clipboardModel.count // 현재 클립보드에 올려져있는 글 갯수
      case .noClipboard:
        return 0
      }
    case .normalSystem:
      return 10
    }
    
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let section = BoardViewType.allCases[indexPath.section]
    switch section {
    case .clipboard:
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ClipboardCollectionViewCell.identifier, for: indexPath) as? ClipboardCollectionViewCell ?? ClipboardCollectionViewCell()
      cell.configureUI(with: clipboardModel.map({ model in
        return ClipboardCollectionViewCellModel(type: model.type, contentImageString: model.feedImageURL, contentText: model.content)
      })[indexPath.row]
      )
      return cell
    case .normalSystem:
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BoardCollectionViewCell.identifier, for: indexPath) as? BoardCollectionViewCell ?? BoardCollectionViewCell()
      cell.configure(with: BoardModel(author: "개나리", authorProfileImageLink: nil, date: .now, likeCount: 3, commentCount: 5, title: "게시판 제목", imageLink: nil, content: nil))
      return cell
    }
  }
}



