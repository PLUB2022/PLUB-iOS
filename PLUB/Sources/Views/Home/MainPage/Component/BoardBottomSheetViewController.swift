//
//  BoardBottomSheetViewController.swift
//  PLUB
//
//  Created by 이건준 on 2023/03/20.
//

import UIKit

import RxSwift
import SnapKit
import Then

protocol BoardBottomSheetDelegate: AnyObject {
  func selectedBoardSheetType(type: BoardBottomSheetType)
}

enum BoardBottomSheetType {
  case fix // 클립보드 고정
  case modify // 게시글 수정
  case report // 게시글 신고
  case delete // 게시글 삭제
}

final class BoardBottomSheetViewController: BottomSheetViewController {
  
  // MARK: - Properties
  
  weak var delegate: BoardBottomSheetDelegate?
  
  private let accessType: AccessType
  private let isPinned: Bool
  
  // MARK: - UI Components
  
  private let contentStackView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 8
  }
  
  private lazy var clipboardFixView = BottomSheetListView(
    text: isPinned ? "클립보드 고정 해제" : "클립보드에 고정",
    image: "pinBlack"
  )
  private lazy var modifyBoardView  = BottomSheetListView(text: "게시글 수정", image: "editBlack")
  private lazy var reportBoardView  = BottomSheetListView(text: "게시글 신고", image: "lightBeaconMain")
  private lazy var deleteBoardView  = BottomSheetListView(text: "게시글 삭제", image: "trashRed", textColor: .error)
  
  
  // MARK: - Initializations
  
  init(accessType: AccessType, isPinned: Bool) {
    self.accessType = accessType
    self.isPinned = isPinned
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Configurations
  
  override func setupLayouts() {
    super.setupLayouts()
    contentView.addSubview(contentStackView)
    
    if accessType != .normal {
      contentStackView.addArrangedSubview(clipboardFixView)
    }
    
    if accessType == .author {
      contentStackView.addArrangedSubview(modifyBoardView)
      contentStackView.addArrangedSubview(deleteBoardView)
    } else {
      contentStackView.addArrangedSubview(reportBoardView)
    }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    let heightConstraint: (ConstraintMaker) -> Void = { $0.height.equalTo(Metrics.Size.listHeight) }
    
    if accessType != .normal {
      clipboardFixView.snp.makeConstraints(heightConstraint)
    }
    
    if accessType == .author {
      modifyBoardView.snp.makeConstraints(heightConstraint)
      deleteBoardView.snp.makeConstraints(heightConstraint)
    } else {
      reportBoardView.snp.makeConstraints(heightConstraint)
    }
    
    contentStackView.snp.makeConstraints {
      $0.top.equalToSuperview().inset(Metrics.Margin.top)
      $0.directionalHorizontalEdges.equalToSuperview().inset(Metrics.Margin.horizontal)
      $0.bottom.equalToSuperview().inset(Metrics.Margin.bottom)
    }
  }
  
  override func bind() {
    super.bind()
    if accessType != .normal {
      clipboardFixView.button.rx.tap
        .subscribe(with: self) { owner, _ in
          owner.delegate?.selectedBoardSheetType(type: .fix)
        }
        .disposed(by: disposeBag)
    }
    
    if accessType == .author {
      modifyBoardView.button.rx.tap
        .subscribe(with: self) { owner, _ in
          owner.delegate?.selectedBoardSheetType(type: .modify)
        }
        .disposed(by: disposeBag)
      
      deleteBoardView.button.rx.tap
        .subscribe(with: self) { owner, _ in
          owner.delegate?.selectedBoardSheetType(type: .delete)
        }
        .disposed(by: disposeBag)
    } else {
      reportBoardView.button.rx.tap
        .subscribe(with: self) { owner, _ in
          owner.delegate?.selectedBoardSheetType(type: .report)
        }
        .disposed(by: disposeBag)
    }
  }
}

// MARK: - Enum Type

extension BoardBottomSheetViewController {
  enum AccessType {
    
    /// 호스트
    case host
    
    /// 게시글 저자
    case author
    
    /// 일반
    case normal
  }
}
