//
//  ArchiveViewController.swift
//  PLUB
//
//  Created by 홍승현 on 2023/03/10.
//

import UIKit

import RxSwift
import RxCocoa
import SnapKit
import Then

final class ArchiveViewController: BaseViewController {
  
  // MARK: - Properties
  
  private let viewModel: ArchiveViewModelType
  
  // MARK: - UI Components
  
  // MARK: Header
  
  private let headerStackView = UIStackView().then {
    $0.alignment = .center
  }
  
  private let titleLabel = UILabel().then {
    $0.text = "모임 아카이브"
    $0.font = .h3
  }
  
  private let uploadButton = UIButton(
    configuration: .plubFilledButton(
      title: "업로드",
      contentInsets: .init(top: 5, leading: 8, bottom: 5, trailing: 8)
    )
  )
  
  // MARK: - Initializations
  
  init(viewModel: ArchiveViewModelType) {
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
    view.addSubview(headerStackView)
    
    [titleLabel, uploadButton].forEach {
      headerStackView.addArrangedSubview($0)
    }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    headerStackView.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide)
      $0.directionalHorizontalEdges.equalToSuperview().inset(16)
    }
  }
  
  override func setupStyles() {
    super.setupStyles()
  }
  
  override func bind() {
    super.bind()
  }
}
