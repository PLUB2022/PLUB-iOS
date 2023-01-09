//
//  MeetingNameViewController.swift
//  PLUB
//
//  Created by 김수빈 on 2023/01/08.
//

import UIKit
import SnapKit
import Then

final class MeetingNameViewController: BaseViewController {
  // MARK: - Property
  private let scrollView = UIScrollView().then {
    $0.bounces = false
    $0.contentInsetAdjustmentBehavior = .never
    $0.showsVerticalScrollIndicator = false
  }
  
  private let contentStackView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 38
  }
  
  private let introduceTitleView = InputTextView(
    title: "소개 타이틀",
    placeHolder: "날 좋은날 같이 사진 찍으러 갈 사람~",
    options: [.textCount, .questionMark]
  )
  
  private let nameTitleView = InputTextView(
    title: "모임 이름",
    placeHolder: "우리동네 사진모임"
  )
  
  // MARK: - Life Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  // MARK: - Configuration
  
  override func setupLayouts() {
    super.setupLayouts()
    view.addSubview(scrollView)
    scrollView.addSubview(contentStackView)
    
    contentStackView.addArrangedSubview(introduceTitleView)
    contentStackView.addArrangedSubview(nameTitleView)
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    scrollView.snp.makeConstraints {
        $0.top.equalTo(view.safeAreaLayoutGuide)
        $0.leading.trailing.bottom.equalToSuperview()
    }
    
    contentStackView.snp.makeConstraints {
      $0.edges.equalToSuperview()
      $0.width.equalTo(scrollView.snp.width)
    }
  }
  
  override func setupStyles() {
    super.setupStyles()
    view.backgroundColor = .background
  }
  
  override func bind() {
    super.bind()
  }
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI
struct MeetingNameViewControllerPreview: PreviewProvider {
  static var previews: some View {
    MeetingNameViewController().toPreview()
  }
}
#endif
