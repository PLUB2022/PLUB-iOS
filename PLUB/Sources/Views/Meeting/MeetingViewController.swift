import UIKit

final class MeetingViewController: BaseViewController {
  
  private let viewModel = MeetingViewModel()
  
  private var meetingList: [MyPlubbing] = [] {
    didSet {
      self.collectionView.reloadData()
    }
  }
  
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
  
  private lazy var pageControl = PageControl().then {
    $0.numberOfPages = 1
    $0.isHidden = true
  }
  
  private let collectionViewLayout = UICollectionViewFlowLayout().then {
    $0.minimumInteritemSpacing = 16
    $0.itemSize = CGSize(
      width: Device.width - 30 * 2,
      height: Device.height
      - (Device.topInset + Device.bottomInset)
      - (111 + 25 + 100)
    )
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
    $0.register(MeetingCollectionViewCell.self, forCellWithReuseIdentifier: "MeetingCollectionViewCell")
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
    
    pageControl.snp.makeConstraints {
      $0.top.equalTo(meetingTypeStackView.snp.bottom).offset(24)
      $0.centerX.equalToSuperview()
    }
    
    collectionView.snp.makeConstraints {
      $0.top.equalTo(meetingTypeStackView.snp.bottom).offset(36)
      $0.leading.trailing.equalToSuperview()
      $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(25)
    }
  }
  
  override func setupStyles() {
    super.setupStyles()
    setupNavigationBar()
  }
  
  override func bind() {
    super.bind()
    
    viewModel.meetingList
      .drive(with: self){ owner, data in
        owner.meetingList = data
        owner.pageControl.numberOfPages = data.count
      }
      .disposed(by: disposeBag)
    
    myMeetingButton.rx.tap
      .asDriver()
      .drive(with: self){ owner, _ in
        //
      }
      .disposed(by: disposeBag)
    
    hostButton.rx.tap
      .asDriver()
      .drive(with: self){ owner, _ in
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
    return meetingList.count + 1
  }
    
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(
      withReuseIdentifier: "MeetingCollectionViewCell",
      for: indexPath
    ) as? MeetingCollectionViewCell else { return UICollectionViewCell() }
    
    if indexPath.row < meetingList.count {
      cell.setupData(with: meetingList[indexPath.row])
    } else{
      cell.setupCreateCell()
    }
    return cell
  }
    
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    if indexPath.row < meetingList.count {
      // 플러빙 메인
      let vc = DetailRecruitmentViewController(plubbingID: "\(meetingList[indexPath.row].plubbingID)")
      vc.hidesBottomBarWhenPushed = true
      self.navigationController?.pushViewController(vc, animated: true)
    } else {
      // 모임 생성
      let vc = CreateMeetingViewController()
      vc.hidesBottomBarWhenPushed = true
      self.navigationController?.pushViewController(vc, animated: true)
    }
  }
}
