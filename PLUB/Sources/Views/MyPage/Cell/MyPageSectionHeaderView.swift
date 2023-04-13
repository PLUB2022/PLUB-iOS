//
//  MyPageFoldTableViewCell.swift
//  PLUB
//
//  Created by 김수빈 on 2023/03/12.
//

import UIKit

import RxSwift
import RxCocoa
import SnapKit
import Then

extension PlubbingStatusType {
  var title: String {
    switch self {
    case .recruiting:
      return "모집 중인 모임"
    case .waiting:
      return "대기 중인 모임"
    case .active:
      return "활동 중인 모임"
    case .end:
      return "종료된 모임"
    }
  }
}

protocol MyPageSectionHeaderViewDelegate: AnyObject {
  func foldHeaderView(sectionIndex: Int)
}

final class MyPageSectionHeaderView: UITableViewHeaderFooterView {
  static let identifier = "MyPageSectionHeaderView"
  weak var delegate: MyPageSectionHeaderViewDelegate?
  private let disposeBag = DisposeBag()
  private var sectionIndex: Int? = nil
  
  private let containerView = UIView().then {
    $0.backgroundColor = .white
  }
  
  private let titlelabel = UILabel().then {
    $0.font = .h5
    $0.textColor = .black
  }
  
  private let foldImageView = UIImageView().then {
    $0.image = UIImage(named: "unfoldedArrow")
    $0.highlightedImage = UIImage(named: "foldedArrow")
  }
  
  private let button = UIButton()
  
  override init(reuseIdentifier: String?) {
    super.init(reuseIdentifier: reuseIdentifier)
    setupLayouts()
    setupConstraints()
    bind()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    containerView.roundCorners(corners: [.topLeft, .topRight], radius: 15)
    containerView.layer.addBorder([.top], color: .lightGray, width: 1)
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
  
  private func bind() {
    button.rx.tap
      .asDriver()
      .drive(with: self) { owner, _ in
        guard let sectionIndex = owner.sectionIndex else { return }
        owner.delegate?.foldHeaderView(sectionIndex: sectionIndex)
      }
      .disposed(by: disposeBag)
  }
  
  func setupData(
    with data: MyPageTableViewCellModel,
    sectionIndex: Int
  ) {
    titlelabel.text = data.section.plubbingStatus.title
    
    foldImageView.isHighlighted = !data.isFolded
    
    self.sectionIndex = sectionIndex
  }
}
