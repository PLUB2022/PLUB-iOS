//
//  EditMeetingViewController.swift
//  PLUB
//
//  Created by 김수빈 on 2023/02/09.
//

import UIKit

import SnapKit
import Then

enum EditMeetingType: String, CaseIterable {
  case myMeetingSetting = "내 모임 설정"
  case editRecruitment = "모집글 수정"
  case questionList = "질문 리스트"
}

final class EditMeetingViewController: BaseViewController {
  private let plubbingID: Int
  
  private let contentStackView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 16
    $0.isLayoutMarginsRelativeArrangement = true
    $0.layoutMargins = .init(top: 15, left: 0, bottom: 15, right: 0)
  }
  
  private let titleLabel = UILabel().then {
    $0.text = "설정"
    $0.font = .h2
  }
  
  let subStackView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 0
    $0.layer.cornerRadius = 10
    $0.backgroundColor = .white
  }
  
  let subView = SettingSubview("모임 설정")
  
  init(plubbingID: Int) {
    self.plubbingID = plubbingID
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    view.addSubview(contentStackView)
    
    [titleLabel, subStackView].forEach {
      contentStackView.addArrangedSubview($0)
    }
    
    subStackView.addArrangedSubview(subView)
    addSubViews(stackView: subStackView)
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    contentStackView.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview().inset(16)
      $0.top.equalToSuperview()
    }
    
    subView.snp.makeConstraints {
      $0.height.equalTo(50)
    }
  }
  
  override func setupStyles() {
    super.setupStyles()
  }
  
  private func addSubViews(stackView: UIStackView) {
    EditMeetingType.allCases.enumerated().forEach { index, type in
      let isLast = index == EditMeetingType.allCases.count - 1
      
      let detailSubview = SettingDetailSubView(type.rawValue, isLast: isLast)
      stackView.addArrangedSubview(detailSubview)
      detailSubview.snp.makeConstraints {
        $0.height.equalTo(52)
      }
      
      detailSubview.button
        .rx.tap
        .asDriver()
        .drive(with: self) { owner, _ in
          switch type {
          case .myMeetingSetting:
            owner.moveToMyMeetingSetting()
          case .editRecruitment:
            owner.moveToEditRecruitment()
          case .questionList:
            owner.moveToQuestionList()
          }
        }
        .disposed(by: disposeBag)
    }
  }
  
  private func moveToMyMeetingSetting() {
    let vc = MeetingInfoViewController(viewModel: MeetingInfoViewModel(plubbingID: plubbingID))
    navigationController?.pushViewController(vc, animated: true)
  }
  
  private func moveToEditRecruitment() {
    let vc = RecruitPostViewController(viewModel: RecruitPostViewModel(plubbingID: plubbingID))
    navigationController?.pushViewController(vc, animated: true)
  }
  
  private func moveToQuestionList() {
    let vc = GuestQuestionViewController(viewModel: GuestQuestionViewModel(plubbingID: plubbingID))
    navigationController?.pushViewController(vc, animated: true)
  }
}
