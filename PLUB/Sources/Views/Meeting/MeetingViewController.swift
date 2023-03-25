import UIKit

import RxSwift
import RxCocoa
import SnapKit
import Then

final class MeetingViewController: BaseViewController {
  
  private let viewModel = MeetingViewModel()
  
  private var meetingList: [MeetingCellModel] = [] {
    didSet {
      self.collectionView.reloadData()
    }
  }
  
  private var previousIndex: Int?
  
  private let meetingTypeStackView = UIStackView().then {
    $0.axis = .horizontal
    $0.spacing = 16
    $0.alignment = .center
  }
  
  private let lineView = UIView().then {
    $0.backgroundColor = .black
  }
  
  private let myMeetingButton = UIButton().then {
    $0.setTitle("내 모임", for: .normal)
    $0.setTitleColor(.mediumGray, for: .normal)
    $0.titleLabel?.font = .h4
  }
  
  private let hostButton = UIButton().then {
    $0.setTitle("호스트", for: .normal)
    $0.setTitleColor(.black, for: .normal)
    $0.titleLabel?.font = .h4
  }
  
  private let pageControl = PageControl().then {
    $0.numberOfPages = 1
  }
  
  private let collectionViewLayout = UICollectionViewFlowLayout().then {
    $0.minimumInteritemSpacing = 0
    $0.minimumLineSpacing = Constants.itemSpacing
    $0.itemSize = Constants.itemSize
    $0.scrollDirection = .horizontal
  }
  
  private lazy var collectionView = UICollectionView(
    frame: .zero,
    collectionViewLayout: collectionViewLayout
  ).then {
    $0.backgroundColor = .background
    $0.showsHorizontalScrollIndicator = false
    $0.delegate = self
    $0.dataSource = self
    $0.isScrollEnabled = true
    $0.clipsToBounds = true
    $0.register(MeetingCollectionViewCell.self, forCellWithReuseIdentifier: "MeetingCollectionViewCell")
    $0.register(MeetingCollectionMoreCell.self, forCellWithReuseIdentifier: "MeetingCollectionMoreCell")
    $0.isPagingEnabled = false
    $0.contentInsetAdjustmentBehavior = .never
    $0.contentInset = Constants.collectionViewContentInset
    $0.decelerationRate = .fast
    $0.translatesAutoresizingMaskIntoConstraints = false
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    viewModel.fetchMyMeeting()
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    [meetingTypeStackView, pageControl, collectionView].forEach {
      view.addSubview($0)
    }
    
    [myMeetingButton, lineView, hostButton].forEach {
      meetingTypeStackView.addArrangedSubview($0)
    }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    meetingTypeStackView.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide).inset(51)
      $0.height.equalTo(24)
      $0.centerX.equalToSuperview()
    }
    
    lineView.snp.makeConstraints {
      $0.width.equalTo(1)
      $0.height.equalTo(20)
    }
    
    collectionView.snp.makeConstraints {
      $0.top.equalTo(meetingTypeStackView.snp.bottom).offset(36)
      $0.leading.trailing.equalToSuperview()
      $0.height.equalTo(433)
    }
    
    pageControl.snp.makeConstraints {
      $0.top.equalTo(collectionView.snp.bottom).offset(24)
      $0.centerX.equalToSuperview()
    }
  }
  
  override func setupStyles() {
    super.setupStyles()
    setupNavigationBar()
  }
  
  override func bind() {
    super.bind()
    
    viewModel.meetingList
      .drive(with: self) { owner, data in
        owner.meetingList = data
        owner.pageControl.numberOfPages = data.count
      }
      .disposed(by: disposeBag)
    
    myMeetingButton.rx.tap
      .asDriver()
      .drive(with: self) { owner, _ in
        //
      }
      .disposed(by: disposeBag)
    
    hostButton.rx.tap
      .asDriver()
      .drive(with: self) { owner, _ in
       //
      }
      .disposed(by: disposeBag)
  }
  
  private func setupNavigationBar() {
    let logoImageView = UIImageView().then {
      $0.image = UIImage(named: "plubIcon522x147")
      $0.contentMode = .scaleAspectFill
    }
    
    self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: logoImageView)
  }
}
extension MeetingViewController: UICollectionViewDelegate, UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return meetingList.count
  }
    
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
    if indexPath.row < meetingList.count - 1 {
      guard let cell = collectionView.dequeueReusableCell(
        withReuseIdentifier: MeetingCollectionViewCell.identifier,
        for: indexPath
      ) as? MeetingCollectionViewCell else { return UICollectionViewCell() }
      cell.setupData(with: meetingList[indexPath.row])
      return cell
    } else {
      guard let cell = collectionView.dequeueReusableCell(
        withReuseIdentifier: MeetingCollectionMoreCell.identifier,
        for: indexPath
      ) as? MeetingCollectionMoreCell else { return UICollectionViewCell() }
      cell.setupData(isDimmed: meetingList[indexPath.row].isDimmed)
      return cell
    }
  }
    
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    if indexPath.row < meetingList.count - 1 {
      guard let plubbing = meetingList[indexPath.row].plubbing else { return }
      // 플러빙 메인
      let vc = MainPageViewController(plubbingID: plubbing.plubbingID)
      vc.navigationItem.largeTitleDisplayMode = .never
      vc.hidesBottomBarWhenPushed = true
      self.navigationController?.pushViewController(vc, animated: true)
    } else {
      // 모임 생성
      let vc = CreateMeetingViewController()
      vc.hidesBottomBarWhenPushed = true
      self.navigationController?.pushViewController(vc, animated: true)
    }
  }
  
  func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    let scrolledOffsetX = targetContentOffset.pointee.x + scrollView.contentInset.left
    let cellWidth = Constants.itemSize.width + Constants.itemSpacing
    let index = round(scrolledOffsetX / cellWidth)
    
    targetContentOffset.pointee = CGPoint(
      x: index * cellWidth - scrollView.contentInset.left,
      y: scrollView.contentInset.top
    )
  }
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    guard !meetingList.isEmpty else { return }
    
    let scrolledOffset = scrollView.contentOffset.x + scrollView.contentInset.left
    let cellWidth = Constants.itemSize.width + Constants.itemSpacing
    let index = Int(round(scrolledOffset / cellWidth))
    
    pageControl.currentPage = index
    
    guard index < meetingList.count else { return }
    self.meetingList[index].isDimmed = false
    
    defer {
      self.previousIndex = index
      self.collectionView.reloadData()
    }
    
    guard let previousIndex = self.previousIndex,
      previousIndex != index
    else { return }
    self.meetingList[previousIndex].isDimmed = true
  }
}

extension MeetingViewController {
  private enum Constants {
    static let itemSize = CGSize(width: 300, height: 433)
    static let itemSpacing = CGFloat(16)
    
    static var insetX: CGFloat {
      (Device.width - self.itemSize.width) / 2.0
    }
    static var collectionViewContentInset: UIEdgeInsets {
      UIEdgeInsets(top: 0, left: self.insetX, bottom: 0, right: self.insetX)
    }
  }
}
