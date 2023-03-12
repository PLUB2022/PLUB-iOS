//
//  MyPageFoldTableViewCell.swift
//  PLUB
//
//  Created by 김수빈 on 2023/03/12.
//

import UIKit

import SnapKit
import RxSwift
import RxCocoa

enum MyPageFoldCellType: String {
  case recruiting = "모집 중인 모임"
  case wait = "대기 중인 모임"
  case active = "활동 중인 모임"
  case end = "종료된 모임"
}

protocol MyPageSectionHeaderViewDelegate: AnyObject {
  func foldHeaderView()
}

final class MyPageSectionHeaderView: UITableViewHeaderFooterView {
  static let identifier = "MyPageSectionHeaderView"
  weak var delegate: MyPageSectionHeaderViewDelegate?
  private let disposeBag = DisposeBag()
  
  private let containerView = UIView().then {
    $0.backgroundColor = .white
  }
  
  private let titlelabel = UILabel().then {
    $0.font = .h5
    $0.textColor = .black
    $0.text = "모집 중인 모임"
  }
  
  private let foldImageView = UIImageView().then {
    $0.image = UIImage(named: "foldedArrow")
    $0.highlightedImage = UIImage(named: "unfoldedArrow")
  }
  
  private let button = UIButton()
  
  override init(reuseIdentifier: String?) {
      super.init(reuseIdentifier: reuseIdentifier)
    setupLayouts()
    setupConstraints()
    setupStyles()
    bind()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupLayouts() {
    [containerView, button].forEach {
      addSubview($0)
    }
    
    [titlelabel, foldImageView].forEach {
      containerView.addSubview($0)
    }
  }
  
  private func setupConstraints() {
    containerView.snp.makeConstraints {
      $0.top.equalToSuperview().inset(12)
      $0.leading.trailing.equalToSuperview().inset(16)
      $0.bottom.equalToSuperview()
    }
    
    titlelabel.snp.makeConstraints {
      $0.top.equalToSuperview().inset(16)
      $0.height.equalTo(24)
//      $0.bottom.equalToSuperview().inset(12)
      $0.leading.equalToSuperview().inset(16)
    }
    
    foldImageView.snp.makeConstraints {
      $0.centerY.equalTo(titlelabel.snp.centerY)
      $0.trailing.equalToSuperview().inset(16)
      $0.size.equalTo(24)
    }
    
    button.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
  }
  
  private func setupStyles() {
    setupRoundCorners(isFoldered: true)
  }
  
  private func bind() {
    button.rx.tap
      .asDriver()
      .drive(with: self) { owner, _ in
        owner.delegate?.foldHeaderView()
      }
      .disposed(by: disposeBag)
    
  }
  
  func setupRoundCorners(isFoldered: Bool) {
//    containerView.roundCorners(corners: isFoldered ? [.topLeft, .topRight] : [.allCorners], radius: 15)
  }
}
