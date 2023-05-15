//
//  IntroduceCategoryViewController.swift
//  PLUB
//
//  Created by 이건준 on 2023/01/02.
//

import UIKit

import RxSwift
import RxCocoa
import SnapKit
import Then

final class DetailRecruitmentViewController: BaseViewController {
  
  private let viewModel: DetailRecruitmentViewModelType
  
  private let plubbingID: Int
  
  private var isHost: Bool = false {
    didSet {
      if isHost {
        applyButton.configurationUpdateHandler = applyButton.configuration?.detailRecruitment(
          label: "모집 끝내기"
        )
        surroundMeetingButton.configurationUpdateHandler = surroundMeetingButton.configuration?.detailRecruitment(
          label: "지원자 확인하기"
        )
      }
    }
  }
  
  private var isApplied: Bool = false {
    didSet {
      guard isApplied != oldValue && !isHost else { return }
      applyButton.configurationUpdateHandler = applyButton.configuration?.detailRecruitment(
        label: isApplied ? "지원취소" : "같이 할래요!"
      )
      applyButton.isSelected = !isApplied
      surroundMeetingButton.isSelected = isApplied
    }
  }
  
  private var model: [String] = [] {
    didSet {
      self.introduceTagCollectionView.reloadData()
    }
  }
  
  private let scrollView = UIScrollView().then {
    $0.showsVerticalScrollIndicator = true
    $0.showsHorizontalScrollIndicator = false
    $0.alwaysBounceVertical = true
  }
  
  private lazy var introduceTypeStackView = UIStackView(arrangedSubviews: [
    introduceCategoryTitleView, introduceCategoryInfoView, meetingIntroduceView, introduceTagCollectionView, participantListView, bottomStackView
  ]).then {
    $0.axis = .vertical
    $0.distribution = .equalSpacing
    $0.isLayoutMarginsRelativeArrangement = true
    $0.spacing = 24
    $0.layoutMargins = UIEdgeInsets(top: Device.navigationBarHeight, left: 16.5, bottom: 35 + Device.tabBarHeight, right: 16.5)
  }
  
  private lazy var bottomStackView = UIStackView(arrangedSubviews: [surroundMeetingButton, applyButton]).then {
    $0.axis = .horizontal
    $0.alignment = .center
    $0.distribution = .fillEqually
    $0.spacing = 8
  }
  
  private let surroundMeetingButton = UIButton(configuration: .plain()).then {
    $0.configurationUpdateHandler = $0.configuration?.detailRecruitment(label: "메인으로")
    $0.isSelected = false
  }
  
  private let applyButton = UIButton(configuration: .plain()).then {
    $0.configurationUpdateHandler = $0.configuration?.detailRecruitment(label: "같이 할래요!")
    $0.isSelected = true
  }
  
  private let introduceCategoryTitleView = IntroduceCategoryTitleView()
  
  private let introduceCategoryInfoView = IntroduceCategoryInfoView()
  
  private let meetingIntroduceView = MeetingIntroduceView()
  
  private lazy var introduceTagCollectionView = UICollectionView(frame: .zero, collectionViewLayout: LeftAlignedCollectionViewFlowLayout().then({
    $0.minimumLineSpacing = 8
    $0.minimumInteritemSpacing = 8
  })).then {
    $0.backgroundColor = .background
    $0.register(IntroduceTagCollectionViewCell.self, forCellWithReuseIdentifier: IntroduceTagCollectionViewCell.identifier)
    $0.delegate = self
    $0.dataSource = self
    $0.isScrollEnabled = false
    $0.sizeToFit()
  }
  
  private lazy var participantListView = ParticipantListView().then {
    $0.backgroundColor = .clear
    $0.delegate = self
  }
  
  init(viewModel: DetailRecruitmentViewModelType = DetailRecruitmentViewModel(), plubbingID: Int) {
    self.viewModel = viewModel
    self.plubbingID = plubbingID
    super.init(nibName: nil, bundle: nil)
    bind(plubbingID: plubbingID)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    viewModel.selectPlubbingID.onNext(plubbingID)
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    view.addSubview(scrollView)
    scrollView.addSubview(introduceTypeStackView)
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    scrollView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
    
    introduceTypeStackView.snp.makeConstraints {
      $0.directionalVerticalEdges.width.equalToSuperview()
    }
    
    introduceTypeStackView.setCustomSpacing(16, after: introduceCategoryInfoView)
    
    introduceTagCollectionView.snp.makeConstraints {
      $0.height.greaterThanOrEqualTo(48)
    }
    
    participantListView.snp.makeConstraints {
      $0.leading.equalToSuperview().offset(17.5)
      $0.trailing.lessThanOrEqualToSuperview().offset(-14.14)
      $0.height.equalTo(64)
    }
    
    bottomStackView.snp.makeConstraints {
      $0.height.equalTo(46)
    }
  }
  
  override func setupStyles() {
    super.setupStyles()
    
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(
      image: UIImage(named: "checkBookmark"),
      style: .plain,
      target: self,
      action: #selector(didTappedComponentButton)
    )
  }
  
  func bind(plubbingID: Int) {
    super.bind()
    viewModel.selectPlubbingID.onNext(plubbingID)
    
    viewModel.introduceCategoryTitleViewModel
      .asObservable()
      .withUnretained(self)
      .subscribe(onNext: { owner, model in
        owner.introduceCategoryTitleView.configureUI(with: model)
      })
      .disposed(by: disposeBag)
    
    viewModel.introduceCategoryInfoViewModel
      .asObservable()
      .withUnretained(self)
      .subscribe(onNext: { owner, model in
        owner.introduceCategoryInfoView.configureUI(with: model)
      })
      .disposed(by: disposeBag)
    
    viewModel.participantListViewModel
      .asObservable()
      .withUnretained(self)
      .subscribe(onNext: { owner, model in
        owner.participantListView.configureUI(with: model)
      })
      .disposed(by: disposeBag)
    
    viewModel.meetingIntroduceModel
      .asObservable()
      .withUnretained(self)
      .subscribe(onNext: { owner, model in
        owner.meetingIntroduceView.configureUI(with: model)
      })
      .disposed(by: disposeBag)
    
    viewModel.categories
      .drive(rx.model)
      .disposed(by: disposeBag)
    
    applyButton.rx.tap
      .subscribe(with: self) { owner, _ in
        if !owner.isApplied && !owner.isHost {
          let vc = ApplyQuestionViewController(plubbingID: owner.plubbingID)
          vc.navigationItem.largeTitleDisplayMode = .never
          owner.navigationController?.pushViewController(vc, animated: true)
        } else if owner.isApplied && !owner.isHost {
          let alert = CustomAlertView(
            AlertModel(
              title: "이 모임에 참여하고 싶지\n않으신가요?",
              message: nil,
              cancelButton: "아니오",
              confirmButton: "네",
              height: 210
            )
          ) {
            // 지원취소 [네] 선택했을때의 동작
            owner.viewModel.selectCancelApplication.onNext(())
          }
          alert.show()
        }
        else { // 호스트일 경우, [모집 끝내기] 버튼을 선택했음에 따른 동작 구현
          owner.viewModel.selectEndRecruitment.onNext(())
        }
      }
      .disposed(by: disposeBag)
    
    surroundMeetingButton.rx.tap
      .subscribe(with: self) { owner, _ in
        if !owner.isHost {
          guard let recommendText = owner.introduceCategoryInfoView.recommendedText,
                let meetingTitle = owner.introduceCategoryTitleView.meetingTitle else { return }
          let vc = MainPageViewController(plubbingID: Int(owner.plubbingID), recommendedText: recommendText)
          vc.title = meetingTitle
          vc.navigationItem.largeTitleDisplayMode = .never
          owner.navigationController?.pushViewController(vc, animated: true)
        }
        else { // [지원자 확인하기] 버튼 선택할때
          
        }
      }
      .disposed(by: disposeBag)
    
    viewModel.isApplied
      .drive(rx.isApplied)
      .disposed(by: disposeBag)
    
    viewModel.successCancelApplication
      .emit(with: self) { owner, _ in
        owner.viewModel.selectPlubbingID.onNext(plubbingID)
      }
      .disposed(by: disposeBag)
    
    viewModel.isHost
      .emit(to: rx.isHost)
      .disposed(by: disposeBag)
  }
  
  @objc private func didTappedComponentButton() {
    
  }
}

extension DetailRecruitmentViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return model.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: IntroduceTagCollectionViewCell.identifier, for: indexPath) as? IntroduceTagCollectionViewCell ?? IntroduceTagCollectionViewCell()
    cell.configureUI(with: model[indexPath.row])
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let label = UILabel().then {
      $0.font = .caption
      $0.text = model[indexPath.row]
      $0.sizeToFit()
    }
    let size = label.frame.size
    return CGSize(width: size.width + 16, height: size.height + 4)
  }
}

extension DetailRecruitmentViewController: ParticipantListViewDelegate {
  func didTappedMoreButton(accountInfos: [AccountInfo]) {
    let vc = ParticipantBottomSheetViewController(model: accountInfos)
    present(vc, animated: true)
  }
}
