//
//  GuestQuestionViewController.swift
//  PLUB
//
//  Created by 김수빈 on 2023/02/10.
//

import UIKit

final class GuestQuestionViewController: BaseViewController {
  private let viewModel: GuestQuestionViewModel
  weak var delegate: EditMeetingChildViewControllerDelegate?
  
  private let scrollView = UIScrollView().then {
    $0.bounces = false
    $0.showsVerticalScrollIndicator = false
  }
  
  private let contentStackView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 40
  }
  
  private let tapGesture = UITapGestureRecognizer(
    target: RecruitPostViewController.self,
      action: nil
  ).then {
    $0.numberOfTapsRequired = 1
    $0.cancelsTouchesInView = false
    $0.isEnabled = true
  }
  
  init(viewModel: GuestQuestionViewModel) {
    self.viewModel = viewModel
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
    view.addSubview(scrollView)
    scrollView.addSubview(contentStackView)
  }
  
  override func setupConstraints() {
    super.setupConstraints()
  }
  
  override func setupStyles() {
    super.setupStyles()
  }
  
  override func bind() {
    super.bind()
    
//    viewModel.fetchedMeetingData
//      .withUnretained(self)
//      .subscribe(onNext: { owner, data in
//        owner.setupMeetingData(data: data)
//      })
//      .disposed(by: disposeBag)
    
    tapGesture.rx.event
      .asDriver()
      .drive(onNext: { [weak self] _ in
        guard let self = self else { return }
        self.view.endEditing(true)
      })
      .disposed(by: disposeBag)
  }
  
  private func setupMeetingData(data: EditMeetingInfoRequest) {
    
  }
}
