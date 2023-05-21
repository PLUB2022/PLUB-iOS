//
//  MyTodoSectionHeaderView.swift
//  PLUB
//
//  Created by 김수빈 on 2023/04/29.
//

import UIKit

import RxSwift
import RxCocoa

enum MyActivityType: CaseIterable {
  case todo
  case feed
  
  var titleText: String {
    switch self {
    case .todo:
      return "MY To-Do"
    case .feed:
      return "MY 게시글"
    }
  }
  
  var noneText: String {
    switch self {
    case .todo:
      return "To-Do 추가하러 가기"
    case .feed:
      return "새 게시글 작성하기"
    }
  }
}

protocol MyTodoSectionHeaderViewDelegate: AnyObject {
  func moreButtonTapped(type: MyActivityType)
}

protocol MyTodoSectionHeaderViewPlannerDelegate: AnyObject {
  func todoPlannerButtonTapped()
}

final class MyTodoSectionHeaderView: UITableViewHeaderFooterView {
  static let identifier = "MyTodoSectionHeaderView"
  weak var delegate: MyTodoSectionHeaderViewDelegate?
  weak var plannerDelegate: MyTodoSectionHeaderViewPlannerDelegate?
  
  private let disposeBag = DisposeBag()
  private var type: MyActivityType?
  
  private let titleLabel = UILabel().then {
    $0.font = .h5
    $0.textColor = .black
  }
  
  private let moreButton = UIButton().then {
    $0.titleLabel?.font = .caption
    $0.setTitle("전체보기", for: .normal)
    $0.setTitleColor(.black, for: .normal)
  }
  
  private let todoPlannerButton = UIButton().then {
    $0.setImage(UIImage(named: "planner"), for: .normal)
  }
  
  override init(reuseIdentifier: String?) {
    super.init(reuseIdentifier: reuseIdentifier)
    setupLayouts()
    setupConstraints()
    bind()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupLayouts() {
    [titleLabel, moreButton, todoPlannerButton].forEach {
      contentView.addSubview($0)
    }
  }
  
  private func setupConstraints() {
    titleLabel.snp.makeConstraints {
      $0.top.equalToSuperview().inset(32)
      $0.leading.equalToSuperview().inset(16)
      $0.height.equalTo(23)
      $0.bottom.equalToSuperview().inset(16)
    }
    
    moreButton.snp.makeConstraints {
      $0.centerY.equalTo(titleLabel.snp.centerY)
      $0.trailing.equalToSuperview().inset(16)
    }
    
    todoPlannerButton.snp.makeConstraints {
      $0.size.equalTo(32)
      $0.top.equalToSuperview()
      $0.trailing.equalToSuperview().inset(21)
    }
  }
  
  private func bind() {
    moreButton.rx.tap
      .asDriver()
      .drive(with: self) { owner, _ in
        guard let type = owner.type else { return }
        owner.delegate?.moreButtonTapped(type: type)
      }
      .disposed(by: disposeBag)
    
    todoPlannerButton.rx.tap
      .asDriver()
      .drive(with: self) { owner, _ in
        owner.plannerDelegate?.todoPlannerButtonTapped()
      }
      .disposed(by: disposeBag)
  }
  
  func setupData(
    type: MyActivityType,
    isViewAll: Bool = true,
    isDetail: Bool = false
  ) {
    self.type = type
    titleLabel.text = type.titleText
    moreButton.isHidden = !isViewAll
    todoPlannerButton.isHidden = !(!isViewAll && type == .todo)
    if isDetail {
      titleLabel.snp.updateConstraints {
        $0.top.equalToSuperview()
      }
    }
  }
}
