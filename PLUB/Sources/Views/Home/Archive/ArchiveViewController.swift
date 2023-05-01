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
  
  private let gradientLayer = CAGradientLayer().then {
    $0.locations = [0.7]
    $0.colors = [UIColor.background.cgColor, UIColor.background.withAlphaComponent(0).cgColor]
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
  
  private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).then {
    $0.showsVerticalScrollIndicator = false
    $0.backgroundColor = .background
    $0.register(ArchiveCollectionViewCell.self, forCellWithReuseIdentifier: ArchiveCollectionViewCell.identifier)
  }
  
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
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    viewModel.viewWillAppearObserver.onNext(Void())
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    var frame = headerStackView.bounds
    frame.size.height += 32
    gradientLayer.frame = frame
  }
  
  // MARK: - Configuration
  
  override func setupLayouts() {
    super.setupLayouts()
    view.addSubview(collectionView)
    view.addSubview(headerStackView)
    
    headerStackView.layer.addSublayer(gradientLayer)
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
    
    collectionView.snp.makeConstraints {
      $0.directionalHorizontalEdges.equalToSuperview().inset(16)
      $0.top.equalTo(headerStackView.snp.top)
      $0.bottom.equalTo(view.safeAreaLayoutGuide)
    }
  }
  
  override func setupStyles() {
    super.setupStyles()
  }
  
  override func bind() {
    super.bind()
    defer {
      // 해당 Observer는 한 번만 호출되면 되므로, bind 함수가 끝나기 전 completed 호출
      viewModel.setCollectionViewObserver.onCompleted()
    }
    // Diffable DataSource를 업데이트하기 위해 collectionView 제공
    viewModel.setCollectionViewObserver.onNext(collectionView)
    
    // pop up 창을 띄워줘야한다면 받은 값으로 프로퍼티 인자를 제공하여 Pop Up View를 띄움
    viewModel.presentArchivePopUpObservable
      .subscribe(with: self) { owner, tuple in
        owner.present(ArchivePopUpViewController(
          viewModel: ArchivePopUpViewModel(
            getArchiveDetailUseCase: DefaultGetArchiveDetailUseCase(plubbingID: tuple.plubbingID,
                                                                    archiveID: tuple.archiveID)
          )
        ), animated: true)
      }
      .disposed(by: disposeBag)
    
    collectionView.rx.setDelegate(self).disposed(by: disposeBag)
    
    // 페이징 처리
    collectionView.rx.contentOffset
      .distinctUntilChanged()
      .compactMap { [weak self] offset in
        guard let self else { return nil }
        return (self.collectionView.contentSize.height, offset.y)
      }
      .bind(to: viewModel.offsetObserver)
      .disposed(by: disposeBag)
    
    // 업로드 버튼 액션을 viewModel에게 전달
    uploadButton.rx.tap
      .bind(to: viewModel.uploadButtonObserver)
      .disposed(by: disposeBag)
    
    // 업로드 VC를 보여줘야하는 경우
    viewModel.presentArchiveUploadObservable
      .map { plubbingID, archiveID -> (text: String, viewModel: ArchiveUploadViewModelType) in
        if archiveID == .min {
          return (
            text: "아카이브 업로드",
            viewModel: ArchiveUploadViewModelWithUploadFactory.make(plubbingID: plubbingID)
          )
        }
        return (
          text: "아카이브 수정",
          viewModel: ArchiveUploadViewModelWithEditFactory.make(
            plubbingID: plubbingID,
            archiveID: archiveID
          )
        )
      }
      .subscribe(with: self) { owner, tuple in
        owner.navigationController?.pushViewController(
          ArchiveUploadViewController(archiveTitleText: tuple.text, viewModel: tuple.viewModel),
          animated: true
        )
      }
      .disposed(by: disposeBag)
    
    // 바텀시트를 보여줘야 하는 경우
    viewModel.presentBottomSheetObservable
      .subscribe(with: self) { owner, accessType in
        let bottomSheetVC = ArchiveBottomSheetViewController(accessType: accessType)
        bottomSheetVC.delegate = owner
        owner.present(bottomSheetVC, animated: true)
      }
      .disposed(by: disposeBag)
  }
}

// MARK: - ArchiveBottomSheetDelegate

extension ArchiveViewController: ArchiveBottomSheetDelegate {
  func buttonTapped(type: ArchiveBottomSheetViewController.SelectedType) {
    viewModel.bottomSheetTypeObserver.onNext(type)
  }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension ArchiveViewController: UICollectionViewDelegateFlowLayout {
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    // top: 헤더뷰의 높이(30) + 헤더뷰와 첫 번째 셀 사이의 거리(32)
    // 이렇게 처리한 이유: collectionView의 top constraint가 헤더뷰의 top과 같기 때문
    return .init(top: 30 + 32, left: 0, bottom: 0, right: 0)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: view.frame.width - 32, height: 104)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 0
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    viewModel.selectedArchiveCellObserver.onNext(indexPath)
  }
}
