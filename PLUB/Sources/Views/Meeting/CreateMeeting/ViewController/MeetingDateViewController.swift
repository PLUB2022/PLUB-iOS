//
//  MeetingDateViewController.swift
//  PLUB
//
//  Created by 김수빈 on 2023/01/09.
//

import UIKit

import RxSwift

final class MeetingDateViewController: BaseViewController {
  
  private let scrollView = UIScrollView().then {
    $0.bounces = false
    $0.contentInsetAdjustmentBehavior = .never
    $0.showsVerticalScrollIndicator = false
  }
  
  private let contentStackView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 48
  }
  
  private let titleView = CreateMeetingTitleView(
    title: "언제, 어디서 만날까요?",
    description: "모임 요일, 온/오프라인, 장소정보를 적어주세요."
  )
  
  private let dateStackView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 8
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
  
  private let timeTitlelabel = UILabel().then {
    $0.text = "생년월일"
    $0.font = .subtitle
    $0.textColor = .black
  }
  
  private let timeControl = TimeControl()

  private let locationTitlelabel = UILabel().then {
    $0.text = "생년월일"
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
  
  init() {
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    view.addSubview(scrollView)
    scrollView.addSubview(contentStackView)
    
    [titleView, dateTitlelabel, dateCollectionView, timeTitlelabel, timeControl, locationTitlelabel, locationStackView, locationLabel, locationControl].forEach {
      contentStackView.addArrangedSubview($0)
    }
    
    [onlineButton, offlineButton].forEach {
      locationStackView.addArrangedSubview($0)
    }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    scrollView.snp.makeConstraints {
        $0.top.equalTo(view.safeAreaLayoutGuide)
        $0.leading.trailing.bottom.equalToSuperview().inset(24)
    }
    
    contentStackView.snp.makeConstraints {
      $0.edges.equalToSuperview()
      $0.width.equalTo(scrollView.snp.width)
    }
    
    dateCollectionView.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview()
      $0.height.equalTo(72)
    }
    
    [dateTitlelabel, timeTitlelabel, locationTitlelabel, locationLabel].forEach{
      $0.snp.makeConstraints {
        $0.height.equalTo(19)
      }
      contentStackView.setCustomSpacing(8, after: $0)
    }
    
    [timeControl, onlineButton, offlineButton, locationControl].forEach{
      $0.snp.makeConstraints {
        $0.height.equalTo(46)
      }
    }
    
    [dateCollectionView, timeControl, locationStackView].forEach{
      contentStackView.setCustomSpacing(40, after: $0)
    }
  }
  
  override func setupStyles() {
    super.setupStyles()
  }
  
  override func bind() {
    super.bind()
    
    Observable.of(["월요일", "화요일", "수요일", "목요일", "금요일", "토요일", "일요일", "요일 무관"])
      .bind(to: dateCollectionView.rx.items) { _, row, item -> UICollectionViewCell in
        guard let cell = self.dateCollectionView.dequeueReusableCell(
          withReuseIdentifier: WeekDateCollectionViewCell.identifier,
          for: IndexPath(row: row, section: 0)
        ) as? WeekDateCollectionViewCell
        else { return UICollectionViewCell() }
        
        cell.setupData(dateText: item)
        return cell
      }
      .disposed(by: disposeBag)
    
    onlineButton.rx.tap
       .withUnretained(self)
       .subscribe(onNext: { owner, _ in
         owner.onlineButton.isSelected = true
         owner.offlineButton.isSelected = false
       })
       .disposed(by: disposeBag)
    
    offlineButton.rx.tap
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
         owner.onlineButton.isSelected = false
         owner.offlineButton.isSelected = true
       })
       .disposed(by: disposeBag)
    
    timeControl.rx.tap
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        let vc = DateBottomSheetViewController(type: .time, buttonTitle: "생일 입력 완료")
        vc.modalPresentationStyle = .overFullScreen
        vc.delegate = owner
        owner.parent?.present(vc, animated: false)
      })
      .disposed(by: disposeBag)
    
    locationControl.rx.tap
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        let vc = LocationBottomSheetViewController()
        vc.modalPresentationStyle = .overFullScreen
//        vc.delegate = owner
        owner.parent?.present(vc, animated: false)
      })
      .disposed(by: disposeBag)
  }
}

extension MeetingDateViewController: DateBottomSheetDelegate {
  func selectDate(date: Date) {
    timeControl.date = date
    timeControl.isSelected = true
  }
  
  func kakao(){
    KakaoLocationService.shared.searchPlace(
      quary: KakaoLocationRequest(
        query: "동탄 호수공원",
        page: "1"
      )
    )
    .subscribe(onNext: { result in
        
    })
  }
}
