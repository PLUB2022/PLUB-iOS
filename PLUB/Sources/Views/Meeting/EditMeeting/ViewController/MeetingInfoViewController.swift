//
//  MeetingInfoViewController.swift
//  PLUB
//
//  Created by 김수빈 on 2023/02/10.
//

import UIKit

final class MeetingInfoViewController: BaseViewController {
  private let viewModel: MeetingInfoViewModel
  
  private let contentStackView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 40
  }
  
  private let dateTitlelabel = UILabel().then {
    $0.text = "우리 언제 만나요?"
    $0.font = .subtitle
    $0.textColor = .black
  }
  
  private let dateLayout = UICollectionViewFlowLayout().then {
    $0.minimumLineSpacing = 8
    $0.minimumInteritemSpacing = 16
    $0.itemSize = CGSize(
      width: (Device.width - 50 - 16 * 3) / 4,
      height: 32
    )
  }
  
  private lazy var dateCollectionView = UICollectionView(
    frame: .zero,
    collectionViewLayout: dateLayout
  ).then {
    $0.register(
      WeekDateCollectionViewCell.self,
      forCellWithReuseIdentifier: WeekDateCollectionViewCell.identifier
    )
    $0.isScrollEnabled = false
    $0.backgroundColor = .clear
  }
  
  private let locationTitlelabel = UILabel().then {
    $0.text = "온/오프라인"
    $0.font = .subtitle
    $0.textColor = .black
  }
  
  private let locationStackView = UIStackView().then {
    $0.axis = .horizontal
    $0.spacing = 16
    $0.distribution = .fillEqually
  }
  
  private let onlineButton: UIButton = UIButton(configuration: .plain()).then {
    $0.configurationUpdateHandler = $0.configuration?.list(label: "온라인")
  }
  
  private let offlineButton = UIButton(configuration: .plain()).then {
    $0.configurationUpdateHandler = $0.configuration?.list(label: "오프라인")
  }
  
  private let locationLabel = UILabel().then {
    $0.text = "모이는 장소를 알려주세요!"
    $0.font = .body2
    $0.textColor = .deepGray
  }
  
  private let locationControl = LocationControl()
  
  private let peopleCountLabel = UILabel().then {
    $0.text = "몇 명인가요?"
    $0.font = .subtitle
    $0.textColor = .black
  }
  
  private let slider = UISlider().then {
    $0.value = 0
    $0.tintColor = .main
    $0.minimumValue = 4
    $0.maximumValue = 20
  }
  
  private let peopleNumberToolTip = PeopleNumberToolTip()
  
  private let countStactView = UIStackView().then {
    $0.axis = .horizontal
    $0.spacing = 0
    $0.distribution = .equalSpacing
    $0.translatesAutoresizingMaskIntoConstraints = false
  }
  
  private let minCountLabel = UILabel().then {
    $0.text = "4명"
    $0.font = .caption
    $0.textColor = .black
    $0.textAlignment = .left
  }
  
  private let maxCountLabel = UILabel().then {
    $0.text = "20명"
    $0.font = .caption
    $0.textColor = .black
    $0.textAlignment = .right
  }
  
  private let saveButton = UIButton(configuration: .plain()).then {
    $0.configurationUpdateHandler = $0.configuration?.plubButton(label: "저장")
  }
  
  init(viewModel: MeetingInfoViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    viewModel.fetchMeetingData()
  }

  override func setupLayouts() {
    super.setupLayouts()
    [contentStackView, peopleNumberToolTip, saveButton].forEach {
      view.addSubview($0)
    }
    
    [dateTitlelabel, dateCollectionView, locationTitlelabel, locationStackView, locationLabel, locationControl, peopleCountLabel, slider, countStactView].forEach {
      contentStackView.addArrangedSubview($0)
    }
    
    [onlineButton, offlineButton].forEach {
      locationStackView.addArrangedSubview($0)
    }
    
    [minCountLabel, maxCountLabel].forEach {
      countStactView.addArrangedSubview($0)
    }
    
    saveButton.snp.makeConstraints {
      $0.bottom.equalToSuperview().inset(26)
      $0.height.width.equalTo(46)
      $0.leading.trailing.equalToSuperview().inset(16)
    }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    contentStackView.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview().inset(24)
      $0.top.equalTo(view.safeAreaLayoutGuide).offset(16)
    }
    
    dateCollectionView.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview()
      $0.height.equalTo(72)
    }
    
    [dateTitlelabel, locationTitlelabel, locationLabel].forEach{
      $0.snp.makeConstraints {
        $0.height.equalTo(19)
      }
      contentStackView.setCustomSpacing(8, after: $0)
    }
    
    [onlineButton, offlineButton, locationControl].forEach{
      $0.snp.makeConstraints {
        $0.height.equalTo(46)
      }
    }
    
    [dateCollectionView, locationStackView].forEach{
      contentStackView.setCustomSpacing(40, after: $0)
    }
    
    slider.snp.makeConstraints {
      $0.height.equalTo(30)
    }
    
    contentStackView.setCustomSpacing(3, after: slider)
    
    peopleNumberToolTip.snp.makeConstraints {
      $0.width.equalTo(58)
      $0.height.equalTo(31)
      $0.bottom.equalTo(slider.snp.top).offset(-2)
      $0.leading.equalToSuperview().inset(8.5)
    }
  }
  
  override func setupStyles() {
    super.setupStyles()
    title = "내 모임 설정"
  }
  
  override func bind() {
    super.bind()
    
    viewModel.fetchedMeetingData
      .withUnretained(self)
      .subscribe(onNext: { owner, data in
        owner.setupMeetingData(data: data)
      })
      .disposed(by: disposeBag)
    
    viewModel.dateCellData
      .bind(to: dateCollectionView.rx.items) { _, row, item -> UICollectionViewCell in
        guard let cell = self.dateCollectionView.dequeueReusableCell(
          withReuseIdentifier: WeekDateCollectionViewCell.identifier,
          for: IndexPath(row: row, section: 0)
        ) as? WeekDateCollectionViewCell
        else { return UICollectionViewCell() }
        
        cell.setupData(data: item)
        return cell
      }
      .disposed(by: disposeBag)
    
    dateCollectionView.rx.modelSelected(MeetingDateCollectionViewCellModel.self)
      .withUnretained(self)
      .subscribe(onNext: { owner, data in
        owner.viewModel.updateDate(data: data)
      })
      .disposed(by: disposeBag)
    
    onlineButton.rx.tap
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        owner.changeOnOffButton(state: true)
        owner.viewModel.onOffInputRelay.accept(.online)
      })
      .disposed(by: disposeBag)
    
    offlineButton.rx.tap
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        owner.changeOnOffButton(state: false)
        owner.viewModel.onOffInputRelay.accept(.offline)
      })
       .disposed(by: disposeBag)
    
    locationControl.rx.tap
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        let vc = LocationBottomSheetViewController()
        vc.delegate = owner
        owner.parent?.present(vc, animated: true)
      })
      .disposed(by: disposeBag)
    
    let sliderValue = slider.rx.value
      .map { Int($0) }
    
    sliderValue
      .bind(to: viewModel.peopleNumberRelay)
      .disposed(by: disposeBag)
    
    sliderValue
      .withUnretained(self)
      .asDriver(onErrorDriveWith: .empty())
      .skip(1)
      .drive(onNext: { owner, value in
        owner.peopleNumberToolTip.setupCountLabelText(peopleCount: value)
        owner.peopleNumberToolTip.center = owner.getSliderThumbCenter(slider: owner.slider)
      })
      .disposed(by: disposeBag)
    
    viewModel.isBtnEnabled
      .distinctUntilChanged()
      .drive(with: self){ owner, state in
        owner.saveButton.isEnabled = state
      }
      .disposed(by: disposeBag)
    
    saveButton.rx.tap
      .asDriver()
      .drive(with: self) { owner, _ in
        owner.viewModel.requestEditMeeting()
      }
      .disposed(by: disposeBag)
    
    viewModel.successEditQuestion
      .withUnretained(self)
      .subscribe(onNext: { owner, state in
        owner.navigationController?.popViewController(animated: true)
      })
      .disposed(by: disposeBag)
  }
}

extension MeetingInfoViewController: LocationBottomSheetDelegate {
  func selectLocation(location: Location) {
    locationControl.setLocationLabelText(text: location.placeName ?? "")
    locationControl.isSelected = true
    viewModel.locationInputRelay.accept(location)
  }
}

extension MeetingInfoViewController {
  private func setupMeetingData(data: EditMeetingInfoRequest) {
    changeOnOffButton(state: data.onOff == .online ? true : false)
    peopleNumberToolTip.setupCountLabelText(peopleCount: data.peopleNumber)
    peopleNumberToolTip.center = getSliderThumbCenter(slider: slider)
    guard let placeName = data.placeName, !placeName.isEmpty else { return }
    locationControl.setLocationLabelText(text: placeName)
    locationControl.isSelected = true
  }
  
  private func changeOnOffButton(state: Bool) { // OnLine: true, OffLine: false
    onlineButton.isSelected = state
    offlineButton.isSelected = !state

    [locationLabel, locationControl].forEach {
      $0.isHidden = state
    }
  }
  
  private func getSliderThumbCenter(slider: UISlider) -> CGPoint {
    let sliderTrack: CGRect = slider.trackRect(forBounds: slider.bounds) // slider 트랙 좌표
    let sliderThumb: CGRect = slider.thumbRect(forBounds: slider.bounds, trackRect: sliderTrack, value: slider.value) // slider 원 좌표
    
    let centerX = slider.frame.origin.x + sliderThumb.origin.x + sliderThumb.size.width / 2 + 24 // slider x좌표 + slider 원 x좌표 + slider 너비 / 2 + contentStackView의 leading inset 값
    let centerY = slider.frame.origin.y - 15.5 - 2 // slider y좌표 - peopleNumberToolTip 높이 / 2 - peopleNumberToolTip과 slider간 padding 값
    
    return CGPoint(x: centerX, y: centerY)
  }
}
