// 
//  ArchiveUploadViewController.swift
//  PLUB
//
//  Created by 홍승현 on 2023/04/17.
//

import UIKit

import RxSwift
import RxCocoa
import SnapKit
import Then

final class ArchiveUploadViewController: BaseViewController {
  
  // MARK: - Properties
  
  private let viewModel: ArchiveUploadViewModelType
  
  // MARK: - UI Components
  
  private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: .init()).then {
    $0.register(
      ArchiveUploadHeaderView.self,
      forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
      withReuseIdentifier: ArchiveUploadHeaderView.identifier
    )
    $0.backgroundColor = .background
  }
  
  private let completeButton = UIButton(configuration: .plain()).then {
    $0.configurationUpdateHandler = $0.configuration?.plubButton(label: "완료")
    $0.isEnabled = false
  }
  
  // MARK: - Initializations
  
  init(viewModel: ArchiveUploadViewModelType) {
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
    [collectionView, completeButton].forEach {
      view.addSubview($0)
    }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    collectionView.snp.makeConstraints {
      $0.directionalHorizontalEdges.equalToSuperview().inset(Margin.horizontal)
      $0.top.equalTo(view.safeAreaLayoutGuide)
      $0.bottom.equalTo(completeButton.snp.top)
    }
    
    completeButton.snp.makeConstraints {
      $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
      $0.directionalHorizontalEdges.equalToSuperview().inset(Margin.horizontal)
      $0.height.equalTo(Size.buttonHeight)
    }
  }
  
  override func setupStyles() {
    super.setupStyles()
  }
  
  override func bind() {
    super.bind()
  }
}

private extension ArchiveUploadViewController {
  
  enum Margin {
    static let horizontal = 16
  }
  
  enum Size {
    static let buttonHeight = 46
  }
}
