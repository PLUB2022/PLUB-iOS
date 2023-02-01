//
//  MeetingSummaryViewController.swift
//  PLUB
//
//  Created by 김수빈 on 2023/01/31.
//

import UIKit

final class MeetingSummaryViewController: BaseViewController {
  
  private var viewModel: MeetingSummaryViewModel
  
  init(
    viewModel: MeetingSummaryViewModel
  ) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Life Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  // MARK: - Configuration
  
  override func setupLayouts() {
    super.setupLayouts()
  }
  
  override func setupConstraints() {
    super.setupConstraints()
  }
  
  override func setupStyles() {
    super.setupStyles()
    view.backgroundColor = .systemBackground
  }
  
  override func bind() {
    super.bind()
  }
}
