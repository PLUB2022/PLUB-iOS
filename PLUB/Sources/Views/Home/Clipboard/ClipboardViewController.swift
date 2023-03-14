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
    collectionView.rx.setDelegate(self).disposed(by: disposeBag)
    
    viewModel.fetchClipboards
      .drive(collectionView.rx.items(cellIdentifier: BoardCollectionViewCell.identifier, cellType: BoardCollectionViewCell.self)) { index, model, cell in
        cell.configure(with: model.toBoardModel)
      }
      .disposed(by: disposeBag)
    
    // 선택된 셀의 FeedContent와 댓글 정보를 가져오고
    // BoardDetailViewController의 ViewModel에 전달하면서 navigation push 진행
    collectionView.rx.modelSelected(FeedsContent.self)
      .flatMap { content -> Observable<(content: FeedsContent, comments: [CommentContent])> in
        // content를 가지고 댓글 정보 가져옴
        return FeedsService.shared.fetchComments(plubbingID: content.plubbingID!, feedID: content.feedID)
          .compactMap { result -> [CommentContent]? in
            guard case let .success(response) = result else { return nil }
            return response.data?.content
          }
          .map { (content, $0) } // 게시글 정보와 댓글 내역을 튜플로 감싸서 변환
      }
      .subscribe(with: self) { owner, model in
        owner.navigationController?.pushViewController(
          BoardDetailViewController(viewModel: BoardDetailViewModel(content: model.content, comments: model.comments)),
          animated: true
        )
      }
      .disposed(by: disposeBag)
  }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension ClipboardViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    // 너비 양옆 inset 16을 제외
    return .init(width: view.bounds.width - 16 * 2, height: CGFloat(viewModel.cellHeights[indexPath.item]))
  }
}

// MARK: - Constants

extension ClipboardViewController {
  private enum Metric {
    static let wholeStackViewLeftRight = 16
    static let pinImageViewSize = 24
  }
}
