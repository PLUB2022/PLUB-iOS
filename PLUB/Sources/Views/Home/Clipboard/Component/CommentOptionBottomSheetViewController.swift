//
//  CommentOptionBottomSheetViewController.swift
//  PLUB
//
//  Created by 홍승현 on 2023/04/15.
//

import UIKit

import RxSwift
import RxCocoa
import SnapKit
import Then

protocol CommentOptionBottomSheetDelegate: AnyObject {
  func deleteButtonTapped()
  func editButtonTapped()
  func reportButtonTapped()
}


final class CommentOptionBottomSheetViewController: BottomSheetViewController {
  
  enum UserAccessType {
    
    /// 게시글 작성자
    case author
    
    /// 댓글 작성자 본인
    case `self`
    
    /// 일반 사용자
    case normal
  }
  
  // MARK: - Properties
  
  private let userAccessType: UserAccessType
  
  weak var delegate: CommentOptionBottomSheetDelegate?
  
  // MARK: - UI Components
  
  private let contentStackView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 8
  }
  
  private lazy var reportCommentView = BottomSheetListView(text: "댓글 신고", image: "lightBeaconMain")
  private lazy var editCommentView   = BottomSheetListView(text: "댓글 수정", image: "editBlack")
  private lazy var deleteCommentView = BottomSheetListView(text: "댓글 삭제", image: "trashRed", textColor: .error)
  
  
  // MARK: - Initializations
  
  init(userAccessType: UserAccessType) {
    self.userAccessType = userAccessType
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    contentView.addSubview(contentStackView)
    
    // 신고 UI
    if userAccessType != .`self` {
      contentStackView.addArrangedSubview(reportCommentView)
    } else {
      // 수정 UI
      contentStackView.addArrangedSubview(editCommentView)
    }
    
    if userAccessType != .normal {
      contentStackView.addArrangedSubview(deleteCommentView)
    }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    let heightConstraints: (ConstraintMaker) -> Void = {
      $0.height.equalTo(Metrics.Size.height)
    }
    
    contentStackView.snp.makeConstraints {
      $0.top.equalToSuperview().inset(Metrics.Margin.top)
      $0.directionalHorizontalEdges.equalToSuperview().inset(Metrics.Margin.horizontal)
      $0.bottom.equalToSuperview().inset(Metrics.Margin.bottom)
    }
    
    // 신고 UI Constraints
    if userAccessType != .`self` {
      reportCommentView.snp.makeConstraints(heightConstraints)
    } else {  // 수정 UI Constraints
      editCommentView.snp.makeConstraints(heightConstraints)
    }
    
    // 삭제 UI Constraints
    if userAccessType != .normal {
      deleteCommentView.snp.makeConstraints(heightConstraints)
    }
  }
  
  override func bind() {
    super.bind()
    
    deleteCommentView.button.rx.tap
      .subscribe(with: self) { owner, _ in
        owner.delegate?.deleteButtonTapped()
        owner.dismiss(animated: true)
      }
      .disposed(by: disposeBag)
    
    editCommentView.button.rx.tap
      .subscribe(with: self) { owner, _ in
        owner.delegate?.editButtonTapped()
        owner.dismiss(animated: true)
      }
      .disposed(by: disposeBag)
  }
}
