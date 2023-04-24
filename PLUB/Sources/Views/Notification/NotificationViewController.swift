// 
//  NotificationViewController.swift
//  PLUB
//
//  Created by 홍승현 on 2023/04/24.
//

import UIKit

import RxSwift
import RxCocoa
import SnapKit
import Then

final class NotificationViewController: BaseViewController {
  
  // MARK: - Properties
  
  private let viewModel: NotificationViewModelType
  
  
  // MARK: - Initializations
  
  init(viewModel: NotificationViewModelType) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Life Cycles
  
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
  }
  
  override func bind() {
    super.bind()
  }
}
