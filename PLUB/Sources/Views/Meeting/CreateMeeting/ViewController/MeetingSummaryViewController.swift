//
//  MeetingSummaryViewController.swift
//  PLUB
//
//  Created by 김수빈 on 2023/01/31.
//

import UIKit

final class MeetingSummaryViewController: BaseViewController {
  
  private var viewModel: MeetingSummaryViewModel
  
  private let scrollView = UIScrollView().then {
    $0.showsVerticalScrollIndicator = true
    $0.showsHorizontalScrollIndicator = false
    $0.alwaysBounceVertical = true
  }
  
  private lazy var introduceTypeStackView = UIStackView(arrangedSubviews: [
    introduceCategoryTitleView, introduceCategoryInfoView, meetingIntroduceView, introduceTagCollectionView, bottomStackView
  ]).then {
    $0.axis = .vertical
    $0.alignment = .center
    $0.distribution = .fill
    $0.isLayoutMarginsRelativeArrangement = true
    $0.spacing = 24
    $0.layoutMargins = UIEdgeInsets(top: Device.navigationBarHeight, left: 16.5, bottom: .zero, right: 16.5)
  }
  
  private lazy var bottomStackView = UIStackView(arrangedSubviews: [surroundMeetingButton, applyButton]).then {
    $0.axis = .horizontal
    $0.alignment = .center
    $0.distribution = .fillEqually
    $0.spacing = 8
  }
  
  private let surroundMeetingButton = UIButton(configuration: .plain()).then {
    $0.configurationUpdateHandler = $0.configuration?.plubButton(label: "모임 둘러보기")
    $0.isEnabled = false
  }
  
  private let applyButton = UIButton(configuration: .plain()).then {
    $0.configurationUpdateHandler = $0.configuration?.plubButton(label: "같이 할래요!")
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
    view.addSubview(scrollView)
    scrollView.addSubview(introduceTypeStackView)
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    scrollView.snp.makeConstraints {
      $0.edges.width.equalToSuperview() // 타이틀에 대한 너비까지 잡아줌으로써 Vertical Enabled한 UI를 구성
    }
    
    introduceTypeStackView.snp.makeConstraints {
      $0.edges.width.equalToSuperview()
    }
    
    introduceTagCollectionView.snp.makeConstraints {
      $0.left.right.equalToSuperview().inset(16)
      $0.height.greaterThanOrEqualTo(48)
    }
    
    bottomStackView.snp.makeConstraints {
      $0.right.equalToSuperview().offset(-16.5)
      $0.height.equalTo(46)
    }
  }
  
  override func setupStyles() {
    super.setupStyles()
    setupNavigationBar()
  }
  
  override func bind() {
    super.bind()
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
        recommendedText: data.goal,
        meetingImageUrl: nil,
        meetingImage: viewModel.mainImage,
        categortInfoListModel: CategoryInfoListModel(
          placeName: data.placeName ?? "",
          peopleCount: data.peopleNumber,
          when: data.days
            .map { $0.fromENGToKOR() }
            .joined(separator: ",")
          + " | "
          + "\(data.time)"
        )
      )
    )
    
    meetingIntroduceView.configureUI(
      with: MeetingIntroduceModel(
        title: data.title,
        introduce: data.introduce
      )
    )
    
//    introduceTagCollectionView.configure
  }
}

extension MeetingSummaryViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return viewModel.meetingData.categoryIDs.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: IntroduceTagCollectionViewCell.identifier, for: indexPath) as? IntroduceTagCollectionViewCell ?? IntroduceTagCollectionViewCell()
    cell.configureUI(with: "\(viewModel.meetingData.categoryIDs[indexPath.row])")
    return cell
  }

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
      let label = UILabel().then {
        $0.font = .caption
        $0.text = "\(viewModel.meetingData.categoryIDs[indexPath.row])"
        $0.sizeToFit()
      }
      let size = label.frame.size
      return CGSize(width: size.width + 16, height: size.height + 4)
  }
}
