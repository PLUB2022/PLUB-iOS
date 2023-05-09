//
//  ArchiveBottomSheetViewController.swift
//  PLUB
//
//  Created by 홍승현 on 2023/04/26.
//

import UIKit

import RxSwift
import RxCocoa
import SnapKit
import Then


protocol ArchiveBottomSheetDelegate: AnyObject {
  func buttonTapped(type: ArchiveBottomSheetViewController.SelectedType)
}

final class ArchiveBottomSheetViewController: BottomSheetViewController {
  
  // MARK: - Properties
  
  private let accessType: ArchiveContent.AccessType
  
  weak var delegate: ArchiveBottomSheetDelegate?
  
  // MARK: - UI Components
  
  private let contentStackView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 8
  }
  
  private lazy var editArchiveView    = BottomSheetListView(text: "아카이브 수정", image: "editBlack")
  private lazy var reportArchiveView  = BottomSheetListView(text: "아카이브 신고", image: "lightBeaconMain")
  private lazy var deleteArchiveView  = BottomSheetListView(text: "아카이브 삭제", image: "trashRed", textColor: .error)
  
  // MARK: - Initializations
  
  init(accessType: ArchiveContent.AccessType) {
    self.accessType = accessType
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Configurations
  
  override func setupLayouts() {
    super.setupLayouts()
    contentView.addSubview(contentStackView)
    
    // 신고 UI
    if accessType != .author {
      contentStackView.addArrangedSubview(reportArchiveView)
    } else {
      // 수정 UI
      contentStackView.addArrangedSubview(editArchiveView)
    }
    
    if accessType != .normal {
      contentStackView.addArrangedSubview(deleteArchiveView)
    }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    let heightConstraints: (ConstraintMaker) -> Void = {
      $0.height.equalTo(Metrics.Size.listHeight)
    }
    
    contentStackView.snp.makeConstraints {
      $0.top.equalToSuperview().inset(Metrics.Margin.top)
      $0.directionalHorizontalEdges.equalToSuperview().inset(Metrics.Margin.horizontal)
      $0.bottom.equalToSuperview().inset(Metrics.Margin.bottom)
    }
    
    // 신고 UI Constraints
    if accessType != .author {
      reportArchiveView.snp.makeConstraints(heightConstraints)
    } else {  // 수정 UI Constraints
      editArchiveView.snp.makeConstraints(heightConstraints)
    }
    
    // 삭제 UI Constraints
    if accessType != .normal {
      deleteArchiveView.snp.makeConstraints(heightConstraints)
    }
  }
  
  override func bind() {
    super.bind()
    
    if accessType != .author {
      reportArchiveView.button.rx.tap
        .subscribe(with: self) { owner, _ in
          owner.delegate?.buttonTapped(type: .report)
          owner.dismiss(animated: true)
        }
        .disposed(by: disposeBag)
    } else {
      editArchiveView.button.rx.tap
        .subscribe(with: self) { owner, _ in
          owner.delegate?.buttonTapped(type: .edit)
          owner.dismiss(animated: true)
        }
        .disposed(by: disposeBag)
    }
    if accessType != .normal {
      deleteArchiveView.button.rx.tap
        .subscribe(with: self) { owner, _ in
          owner.delegate?.buttonTapped(type: .delete)
          owner.dismiss(animated: true)
        }
        .disposed(by: disposeBag)
    }
  }
}

// MARK: - Bottom Sheet Selected Type

extension ArchiveBottomSheetViewController {
  enum SelectedType {
    /// 아카이브 수정
    case edit
    
    /// 아카이브 삭제
    case delete
    
    /// 아카이브 신고
    case report
  }
}
