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
    $0.minimumLineSpacing = 16
    $0.itemSize = CGSize(
      width: (Device.width - (50)) / 5,
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
    
    [titleView, dateStackView].forEach {
      contentStackView.addArrangedSubview($0)
    }
    
    [dateTitlelabel, dateCollectionView].forEach {
      dateStackView.addArrangedSubview($0)
    }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    scrollView.snp.makeConstraints {
        $0.top.equalTo(view.safeAreaLayoutGuide)
        $0.leading.trailing.bottom.equalToSuperview()
    }
    
    contentStackView.snp.makeConstraints {
      $0.edges.equalToSuperview()
      $0.width.equalTo(scrollView.snp.width)
    }
    
    dateTitlelabel.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview().inset(24)
      $0.height.equalTo(19)
    }
    
    dateCollectionView.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview().inset(24)
      $0.height.equalTo(340)
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
  }
}
