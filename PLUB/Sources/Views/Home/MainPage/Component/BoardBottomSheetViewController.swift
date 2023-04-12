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
  private let modifyBoardView = BottomSheetListView(text: "게시글 수정", image: "editBlack")
  private let reportBoardView = BottomSheetListView(text: "게시글 신고", image: "lightBeaconMain")
  private let deleteBoardView = BottomSheetListView(text: "게시글 삭제", image: "trashRed", textColor: .error)
  
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
        $0.height.equalTo(50)
      }
    }
    
    contentStackView.snp.makeConstraints {
      $0.top.equalToSuperview().inset(36)
      $0.directionalHorizontalEdges.equalToSuperview().inset(16)
      $0.bottom.equalToSuperview().inset(24)
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
