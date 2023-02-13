//
//  MeetingSummaryViewController.swift
//  PLUB
//
//  Created by 김수빈 on 2023/01/31.
//

import UIKit

final class MeetingSummaryViewController: BaseViewController {
  
  private let viewModel: MeetingSummaryViewModel
  
  private let scrollView = UIScrollView().then {
    $0.showsVerticalScrollIndicator = true
    $0.showsHorizontalScrollIndicator = false
    $0.alwaysBounceVertical = true
  }
  
  private lazy var introduceTypeStackView = UIStackView().then {
    $0.axis = .vertical
    $0.alignment = .center
    $0.distribution = .fill
    $0.isLayoutMarginsRelativeArrangement = true
    $0.spacing = 24
    $0.layoutMargins = UIEdgeInsets(top: Device.navigationBarHeight, left: 16.5, bottom: .zero, right: 16.5)
  }
  
  private let nextButton = UIButton(configuration: .plain()).then {
    $0.configurationUpdateHandler = $0.configuration?.plubButton(label: "다음")
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
    setupData()
  }
  
  // MARK: - Configuration
  
  override func setupLayouts() {
    super.setupLayouts()
    [scrollView, nextButton].forEach {
      view.addSubview($0)
    }
    scrollView.addSubview(introduceTypeStackView)
    
    [introduceCategoryTitleView, introduceCategoryInfoView, meetingIntroduceView, introduceTagCollectionView].forEach {
      introduceTypeStackView.addArrangedSubview($0)
    }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    nextButton.snp.makeConstraints {
      $0.bottom.equalToSuperview().inset(26)
      $0.height.width.equalTo(46)
      $0.leading.trailing.equalToSuperview().inset(16)
    }
    
    scrollView.snp.makeConstraints {
      $0.top.leading.trailing.width.equalToSuperview() // 타이틀에 대한 너비까지 잡아줌으로써 Vertical Enabled한 UI를 구성
      $0.bottom.equalTo(nextButton.snp.top).offset(24)
    }
    
    introduceTypeStackView.snp.makeConstraints {
      $0.directionalEdges.width.equalToSuperview()
    }
    
    introduceTagCollectionView.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview().inset(16)
      $0.height.greaterThanOrEqualTo(48)
    }
  }
  
  override func setupStyles() {
    super.setupStyles()
    setupNavigationBar()
  }
  
  override func bind() {
    super.bind()
    viewModel.presentSuccessPage
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        let vc = MeetingCreateSuccessViewController()
        owner.navigationController?.pushViewController(vc, animated: true)
      })
      .disposed(by: disposeBag)
  }
}

extension MeetingSummaryViewController {
  private func setupNavigationBar() {
    navigationController?.navigationBar.tintColor = .black
    navigationController?.navigationBar.backgroundColor = .background
    navigationItem.leftBarButtonItem = UIBarButtonItem(
      image: UIImage(named: "backButton"),
      style: .plain,
      target: self,
      action: #selector(didTappedBackButton)
    )

    navigationItem.rightBarButtonItem = UIBarButtonItem(
      image: UIImage(named: "blackBookmark"),
      style: .plain,
      target: self,
      action: #selector(didTappedBookmarkButton)
    )
  }
  
  @objc
  private func didTappedBackButton() {
    navigationController?.popViewController(animated: true)
  }
  
  @objc
  private func didTappedBookmarkButton() {
    
  }
  
  private func setupData() {
    let data = viewModel.meetingData
    introduceCategoryTitleView.configureUI(
      with: IntroduceCategoryTitleViewModel(
        title: data.title,
        name: data.name,
        infoText: data.address ?? "")
    )
    
    introduceCategoryInfoView.configureUI(
      with: IntroduceCategoryInfoViewModel(
        recommendedText: "\"\(data.goal)\"",
        meetingImageURL: nil,
        meetingImage: viewModel.mainImage,
        categoryInfoListModel: CategoryInfoListModel(
          placeName: data.placeName ?? "",
          peopleCount: data.peopleNumber,
          dateTime: data.days
            .map { $0.fromENGToKOR() }
            .joined(separator: ",")
          + " | "
          + "\(viewModel.time)"
        )
      )
    )
    
    meetingIntroduceView.configureUI(
      with: MeetingIntroduceModel(
        title: data.title,
        introduce: "\(data.introduce)"
      )
    )
    
    nextButton.rx.tap
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        owner.viewModel.createMeeting()
      })
      .disposed(by: disposeBag)
  }
}

extension MeetingSummaryViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return viewModel.categoryNames.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: IntroduceTagCollectionViewCell.identifier, for: indexPath) as? IntroduceTagCollectionViewCell ?? IntroduceTagCollectionViewCell()
    cell.configureUI(with: viewModel.categoryNames[indexPath.row])
    return cell
  }

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
      let label = UILabel().then {
        $0.font = .caption
        $0.text = viewModel.categoryNames[indexPath.row]
        $0.sizeToFit()
      }
      let size = label.frame.size
      return CGSize(width: size.width + 16, height: size.height + 4)
  }
}
