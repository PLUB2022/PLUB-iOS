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
  
  weak var delegate: BoardBottomSheetDelegate?
  
  private let contentStackView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 8
  }
  
  private let clipboardFixView = BottomSheetListView(text: "클립보드에 고정", image: "pinBlack")
  private let modifyBoardView  = BottomSheetListView(text: "게시글 수정", image: "editBlack")
  private let reportBoardView  = BottomSheetListView(text: "게시글 신고", image: "lightBeaconMain")
  private let deleteBoardView  = BottomSheetListView(text: "게시글 삭제", image: "trashRed", textColor: .error)
  
  override func setupLayouts() {
    super.setupLayouts()
    contentView.addSubview(contentStackView)
    
    [clipboardFixView, modifyBoardView, reportBoardView, deleteBoardView].forEach {
      contentStackView.addArrangedSubview($0)
    }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    [clipboardFixView, modifyBoardView, reportBoardView, deleteBoardView].forEach {
      $0.snp.makeConstraints {
        $0.height.equalTo(Metrics.Size.listHeight)
      }
    }
    
    contentStackView.snp.makeConstraints {
      $0.top.equalToSuperview().inset(Metrics.Margin.top)
      $0.directionalHorizontalEdges.equalToSuperview().inset(Metrics.Margin.horizontal)
      $0.bottom.equalToSuperview().inset(Metrics.Margin.bottom)
    }
  }
  
  override func bind() {
    super.bind()
    clipboardFixView.button.rx.tap
      .subscribe(with: self) { owner, _ in
        owner.delegate?.selectedBoardSheetType(type: .fix)
      }
      .disposed(by: disposeBag)
    
    modifyBoardView.button.rx.tap
      .subscribe(with: self) { owner, _ in
        owner.delegate?.selectedBoardSheetType(type: .modify)
      }
      .disposed(by: disposeBag)
    
    reportBoardView.button.rx.tap
      .subscribe(with: self) { owner, _ in
        owner.delegate?.selectedBoardSheetType(type: .report)
      }
      .disposed(by: disposeBag)
    
    deleteBoardView.button.rx.tap
      .subscribe(with: self) { owner, _ in
        owner.delegate?.selectedBoardSheetType(type: .delete)
      }
      .disposed(by: disposeBag)
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
  
  /// 접근한 뷰 컨트롤러
  enum AccessViewControllerType {
    
    case mainPage
    
    case clipboard
    
    fileprivate var text: String {
      switch self {
      case .clipboard:
        return "클립보드 고정 해제"
      case .mainPage:
        return "클립보드에 고정"
      }
    }
  }
}
