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
  
  private let grabber = UIView().then {
    $0.backgroundColor = .mediumGray
  }
  
  private let contentStackView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 8
    $0.isLayoutMarginsRelativeArrangement = true
    $0.layoutMargins = .init(top: 24, left: 16, bottom: 24, right: 16)
  }
  
  private let clipboardFixView = PhotoBottomSheetListView(text: "클립보드에 고정", image: "pinBlack")
  private let modifyBoardView = PhotoBottomSheetListView(text: "게시글 수정", image: "editBlack")
  private let reportBoardView = PhotoBottomSheetListView(text: "게시글 신고", image: "lightBeaconMain")
  private let deleteBoardView = PhotoBottomSheetListView(text: "게시글 삭제", image: "trashRed", textColor: .error)
  
  override func setupLayouts() {
    super.setupLayouts()
    [clipboardFixView, modifyBoardView, reportBoardView, deleteBoardView].forEach {
      $0.snp.makeConstraints {
        $0.height.equalTo(52)
      }
      contentStackView.addArrangedSubview($0)
    }
    
    [grabber, contentStackView].forEach { contentView.addSubview($0) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    grabber.snp.makeConstraints {
      $0.width.equalTo(48)
      $0.height.equalTo(4)
      $0.centerX.equalToSuperview()
      $0.top.equalToSuperview().inset(8)
    }
    
    contentStackView.snp.makeConstraints {
      $0.top.equalTo(grabber.snp.bottom)
      $0.directionalHorizontalEdges.bottom.equalToSuperview()
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
