//
//  BoardViewController.swift
//  PLUB
//
//  Created by 이건준 on 2023/03/02.
//

import UIKit

import SnapKit
import Then

enum BoardHeaderViewType {
  case clipboard // 클립보드 목록이 하나 이상 존재할 때
  case noClipboard // 클립보드 목록이 하나도 존재하지않을 때
}

protocol BoardViewControllerDelegate: AnyObject {
  func didTappedBoardCollectionViewCell(plubbingID: Int, content: BoardModel)
  func didTappedBoardClipboardHeaderView()
  func didTappedModifyBoard(model: BoardModel)
}

final class BoardViewController: BaseViewController {
  
  weak var delegate: BoardViewControllerDelegate?
  
  private let viewModel: BoardViewModelType
  
  /// 아래 타입의 ClipboardType에 따라 다른 UI를 구성
  private let plubbingID: Int
  
  private var headerType: BoardHeaderViewType = .clipboard {
    didSet {
      collectionView.reloadData()
    }
  }
  
  private var boardModel: [BoardModel] = [] {
    didSet {
      collectionView.reloadData()
    }
  }
  
  private var clipboardModel: [MainPageClipboardViewModel] = [] {
    didSet {
      collectionView.reloadSections([0])
    }
  }
  
  private lazy var collectionView = UICollectionView(
    frame: .zero,
    collectionViewLayout: UICollectionViewFlowLayout().then {
      $0.minimumLineSpacing = 8
    }
  ).then {
    $0.backgroundColor = .background
    $0.register(BoardCollectionViewCell.self, forCellWithReuseIdentifier: BoardCollectionViewCell.identifier)
    $0.register(BoardSystemCollectionViewCell.self, forCellWithReuseIdentifier: BoardSystemCollectionViewCell.identifier)
    $0.register(BoardClipboardHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: BoardClipboardHeaderView.identifier)
    $0.delegate = self
    $0.dataSource = self
    $0.contentInset = .init(top: 16, left: 16, bottom: 16, right: 16)
    $0.alwaysBounceVertical = true
  }
  
  private lazy var longPressedGesture = UILongPressGestureRecognizer(
    target: self,
    action: #selector(handleLongPress(gestureRecognizer:))
  ).then {
    $0.minimumPressDuration = 0.5
    $0.delegate = self
    $0.delaysTouchesBegan = true
  }
  
  init(viewModel: BoardViewModelType = BoardViewModel(), plubbingID: Int) {
    self.viewModel = viewModel
    self.plubbingID = plubbingID
    super.init(nibName: nil, bundle: nil)
    bind(plubbingID: plubbingID)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    viewModel.clearStatus()
  }
  
  override func setupStyles() {
    super.setupStyles()
    collectionView.addGestureRecognizer(longPressedGesture)
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
  
  func bind(plubbingID: Int) {
    super.bind()
    
    viewModel.selectPlubbingID.onNext(plubbingID)
    
    viewModel.fetchedMainpageClipboardViewModel
      .drive(rx.clipboardModel)
      .disposed(by: disposeBag)
    
    viewModel.clipboardListIsEmpty
      .drive(with: self) { owner, isEmpty in
        owner.headerType = isEmpty ? .noClipboard : .clipboard
      }
      .disposed(by: disposeBag)
    
    viewModel.fetchedBoardModel
      .drive(rx.boardModel)
      .disposed(by: disposeBag)
  
    
    collectionView.rx.didScroll
      .subscribe(with: self, onNext: { owner, _ in
        let offSetY = owner.collectionView.contentOffset.y
        let contentHeight = owner.collectionView.contentSize.height
        
        if offSetY > (contentHeight - owner.collectionView.frame.size.height) {
          owner.viewModel.fetchMoreDatas.onNext(())
        }
      })
      .disposed(by: disposeBag)
  }
  
  @objc func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer) {
    
    let location = gestureRecognizer.location(in: collectionView)
    guard let indexPath = collectionView.indexPathForItem(at: location),
          boardModel[indexPath.row].viewType == .normal else { return }
    
    let model = boardModel[indexPath.row]
    if gestureRecognizer.state == .began {
      // 롱 프레스 터치가 시작될 떄
      let isPinned = model.isPinned
      let isHost = model.isHost
      let isAuthor = model.isAuthor
      let bottomSheet: BoardBottomSheetViewController

      if !isAuthor && !isHost {
        bottomSheet = BoardBottomSheetViewController(accessType: .normal, isPinned: isPinned)
      } else if isAuthor {
        bottomSheet = BoardBottomSheetViewController(accessType: .author, isPinned: isPinned)
        bottomSheet.updateSelectedModel(selectedModel: model)
      } else {
        bottomSheet = BoardBottomSheetViewController(accessType: .host, isPinned: isPinned)
      }
      
      let feedID = model.feedID
      viewModel.selectFeedID.onNext(feedID)
      
      bottomSheet.delegate = self
      present(bottomSheet, animated: true)
      
    }
  }
  
}

extension BoardViewController: UICollectionViewDelegate, UICollectionViewDataSource {
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return boardModel.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let boardModel = boardModel[indexPath.row]
    switch boardModel.viewType {
    case .system:
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BoardSystemCollectionViewCell.identifier, for: indexPath) as? BoardSystemCollectionViewCell ?? BoardSystemCollectionViewCell()
      cell.configureUI(with: boardModel)
      return cell
    default:
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BoardCollectionViewCell.identifier, for: indexPath) as? BoardCollectionViewCell ?? BoardCollectionViewCell()
      cell.configure(with: boardModel)
      return cell
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    guard headerType == .clipboard else { return UICollectionReusableView() }
    let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: BoardClipboardHeaderView.identifier, for: indexPath) as? BoardClipboardHeaderView ?? BoardClipboardHeaderView()
    header.configureUI(with: clipboardModel)
    header.delegate = self
    return header
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    delegate?.didTappedBoardCollectionViewCell(plubbingID: plubbingID, content: boardModel[indexPath.row])
  }
  
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
    switch headerType {
    case .clipboard:
      return .init(top: 16, left: 16, bottom: .zero, right: 16)
    case .noClipboard:
      return .init(top: .zero, left: 16, bottom: 16, right: 16)
    }
  }
}

extension BoardViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let boardModel = boardModel[indexPath.row]
    switch boardModel.type {
    case .photo:
      return CGSize(width: collectionView.frame.width - 32, height: 305)
    default:
      return CGSize(width: collectionView.frame.width - 32, height: 114)
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
    switch headerType {
    case .noClipboard:
      return .zero
    case .clipboard:
      return CGSize(width: collectionView.frame.width - 32, height: 260 + 8)
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 8
  }
}

extension BoardViewController: BoardClipboardHeaderViewDelegate {
  func didTappedBoardClipboardHeaderView() {
    delegate?.didTappedBoardClipboardHeaderView()
  }
}

extension BoardViewController: BoardBottomSheetDelegate {
  func selectedBoardSheetType(type: BoardBottomSheetType, model: BoardModel?) {
    switch type {
    case .fix:
      viewModel.selectFix.onNext(())
    case .modify:
      guard let model = model else { return }
      delegate?.didTappedModifyBoard(model: model)
    case .report:
      viewModel.selectFix.onNext(())
    case .delete:
      viewModel.selectDelete.onNext(())
    }
    dismiss(animated: true)
  }
  
}

extension BoardViewController: UIGestureRecognizerDelegate {
  
}

