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
  func calculateHeight(_ height: CGFloat)
}

final class BoardViewController: BaseViewController {
  
  weak var delegate: BoardViewControllerDelegate?
  
  private let viewModel: BoardViewModelType
  
  /// 스크롤 영역에 따른 헤더 뷰 높이변경을 위한 프로퍼티
  private let min: CGFloat = Device.navigationBarHeight
  private let max: CGFloat = 292
  
  /// 아래 타입의 ClipboardType에 따라 다른 UI를 구성
  private let plubbingID: Int
  
  private var headerType: BoardHeaderViewType = .clipboard {
    didSet {
      collectionView.reloadSections([0])
    }
  }
  
  private var boardModel: [BoardModel] = [
    BoardModel(feedID: 0, viewType: .normal, author: "", authorProfileImageLink: "", date: .now, likeCount: 3, commentCount: 3, title: "", imageLink: "", content: ""),
    BoardModel(feedID: 1, viewType: .pin, author: "", authorProfileImageLink: "", date: .now, likeCount: 3, commentCount: 3, title: "", imageLink: "asdasd", content: ""),
    BoardModel(feedID: 2, viewType: .normal, author: "", authorProfileImageLink: "", date: .now, likeCount: 3, commentCount: 3, title: "", imageLink: "", content: ""),
    BoardModel(feedID: 3, viewType: .normal, author: "", authorProfileImageLink: "", date: .now, likeCount: 3, commentCount: 3, title: "", imageLink: "", content: ""),
    BoardModel(feedID: 0, viewType: .normal, author: "", authorProfileImageLink: "", date: .now, likeCount: 3, commentCount: 3, title: "", imageLink: "", content: ""),
    BoardModel(feedID: 0, viewType: .normal, author: "", authorProfileImageLink: "", date: .now, likeCount: 3, commentCount: 3, title: "", imageLink: "", content: ""),
    BoardModel(feedID: 0, viewType: .normal, author: "", authorProfileImageLink: "", date: .now, likeCount: 3, commentCount: 3, title: "", imageLink: "", content: "")
  ] {
    didSet {
      collectionView.reloadSections([0])
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
    $0.bounces = false
    $0.contentInset = .init(top: 16, left: 16, bottom: 16, right: 16)
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
    viewModel.selectPlubbingID.onNext(plubbingID)
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
    
    //    viewModel.selectPlubbingID.onNext(plubbingID)
    //
    //    viewModel.fetchedMainpageClipboardViewModel
    //      .drive(rx.clipboardModel)
    //      .disposed(by: disposeBag)
    //
    //    viewModel.clipboardListIsEmpty
    //      .drive(with: self) { owner, isEmpty in
    //        owner.headerType = isEmpty ? .noClipboard : .clipboard
    //      }
    //      .disposed(by: disposeBag)
    //
    //    viewModel.fetchedBoardModel
    //      .drive(rx.boardModel)
    //      .disposed(by: disposeBag)
  }
  
  @objc func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer) {
    
    let location = gestureRecognizer.location(in: collectionView)
    guard let indexPath = collectionView.indexPathForItem(at: location),
          let cell = collectionView.cellForItem(at: indexPath) as? BoardCollectionViewCell else { return }
    
    if gestureRecognizer.state == .began {
      // 롱 프레스 터치가 시작될 떄
      let bottomSheet = BoardBottomSheetViewController()
      bottomSheet.modalPresentationStyle = .overFullScreen
      present(bottomSheet, animated: false)
    } else if gestureRecognizer.state == .ended {
      // 롱 프레스 터치가 끝날 떄
      guard let feedID = cell.feedID else { return }
      print("피드 \(feedID)")
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
  func didTappedClipboardButton() {
    let vc = ClipboardViewController(viewModel: ClipboardViewModel(plubbingID: plubbingID))
    vc.navigationItem.largeTitleDisplayMode = .never
    self.navigationController?.pushViewController(vc, animated: true)
  }
}

extension BoardViewController: UIGestureRecognizerDelegate {
  
}
