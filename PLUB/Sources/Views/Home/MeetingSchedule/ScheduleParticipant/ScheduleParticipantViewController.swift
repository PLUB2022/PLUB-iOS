//
//  ScheduleParticipantViewController.swift
//  PLUB
//
//  Created by 김수빈 on 2023/03/05.
//

import UIKit

import SnapKit
import Then
import RxSwift

enum ParticipantListType: CaseIterable {
  case oneLine
  case multiLine
}

protocol ScheduleParticipantDelegate: AnyObject {
  func updateAttendStatus()
}

final class ScheduleParticipantViewController: BottomSheetViewController {
  weak var delegate: ScheduleParticipantDelegate?
  private let viewModel: ScheduleParticipantViewModel
  private let data: ScheduleTableViewCellModel
  private var participantListType: ParticipantListType = .oneLine
  
  private let lineView = UIView().then {
    $0.backgroundColor = .mediumGray
    $0.layer.cornerRadius = 2
  }
  
  private lazy var topScheduleView = ScheduleParticipantTopView(data: data)
  
  private let collectionViewLayout = UICollectionViewFlowLayout().then {
    $0.minimumLineSpacing = 8
    $0.minimumInteritemSpacing = 16
    $0.itemSize = CGSize(
      width: 40,
      height: 40
    )
  }
  
  private lazy var participantCollectionView = UICollectionView(
    frame: .zero,
    collectionViewLayout: UICollectionViewFlowLayout()
  ).then {
    $0.register(
      ScheduleParticipantCollectionViewCell.self,
      forCellWithReuseIdentifier: ScheduleParticipantCollectionViewCell.identifier
    )
    $0.register(
      ParticipantCollectionViewCell.self,
      forCellWithReuseIdentifier: ParticipantCollectionViewCell.identifier
    )
    $0.isScrollEnabled = false
    $0.backgroundColor = .clear
    $0.delegate = self
    $0.dataSource = self
  }
  
  private let buttonStackView = UIStackView().then {
    $0.axis = .horizontal
    $0.spacing = 16
    $0.distribution = .fillEqually
  }
  
  private let noAttendButton = UIButton(configuration: .plain()).then {
    $0.configuration?.title = "🙅🏻 불참합니다"
    $0.configuration?.font = .button
    $0.configuration?.background.backgroundColor = .lightGray
    $0.configuration?.background.cornerRadius = 10
    $0.configuration?.baseForegroundColor = .deepGray
  }
  
  private let attendButton =  UIButton(configuration: .plain()).then {
    $0.configurationUpdateHandler = $0.configuration?.plubButton(label: "🙆🏻 참여합니다!")
  }
  
  init(plubbingID: Int, data: ScheduleTableViewCellModel) {
    self.data = data
    self.viewModel = ScheduleParticipantViewModel(
      plubbingID: plubbingID,
      calendarID: data.calendarID
    )
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    [lineView, topScheduleView, participantCollectionView, buttonStackView].forEach {
      contentView.addSubview($0)
    }
    
    [noAttendButton, attendButton].forEach {
      buttonStackView.addArrangedSubview($0)
    }
  }
  
  override func setupConstraints() {
    super.setupConstraints()

    
    lineView.snp.makeConstraints {
      $0.top.equalToSuperview().offset(8)
      $0.height.equalTo(4)
      $0.width.equalTo(48)
      $0.centerX.equalToSuperview()
    }
    
    topScheduleView.snp.makeConstraints {
      $0.top.equalTo(lineView.snp.bottom).offset(16)
      $0.leading.trailing.equalToSuperview().inset(16)
    }
    
    participantCollectionView.snp.makeConstraints {
      $0.top.equalTo(topScheduleView.snp.bottom).offset(16)
      $0.height.equalTo(40)
      $0.leading.trailing.equalToSuperview().inset(16)
    }
    
    buttonStackView.snp.makeConstraints {
      $0.top.equalTo(participantCollectionView.snp.bottom).offset(16)
      $0.height.equalTo(46)
      $0.leading.trailing.equalToSuperview().inset(16)
      $0.bottom.equalToSuperview().inset(20)
    }
  }
  
  override func setupStyles() {
    super.setupStyles()
  }
  
  override func bind() {
    super.bind()
    noAttendButton.rx.tap
      .asDriver()
      .drive(with: self) { owner, _ in
        owner.viewModel.attendSchedule(type: .no)
      }
      .disposed(by: disposeBag)
    
    attendButton.rx.tap
      .asDriver()
      .drive(with: self) { owner, _ in
        owner.viewModel.attendSchedule(type: .yes)
      }
      .disposed(by: disposeBag)
    
    viewModel.successResult
      .drive(with: self) { owner, _ in
        owner.delegate?.updateAttendStatus()
        owner.dismiss(animated: false)
      }
      .disposed(by: disposeBag)
  }
}


extension ScheduleParticipantViewController: UICollectionViewDelegate, UICollectionViewDataSource {
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    let participantCount = data.participants.count
    switch participantListType {
    case .oneLine:
      return participantCount > 7 ? 7 : participantCount
    case .multiLine:
      return participantCount
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
     return UICollectionReusableView()
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    switch participantListType {
    case .oneLine:
      participantListType = .multiLine
      collectionView.reloadData()
      let collectionViewHeight = ceil(Double(data.participants.count) / 4.0) * (16 + 73) - 16
      collectionView.snp.updateConstraints {
        $0.height.equalTo(collectionViewHeight)
      }
    case .multiLine: break
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
      return .zero
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    switch participantListType {
    case .oneLine:
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ScheduleParticipantCollectionViewCell.identifier, for: indexPath) as? ScheduleParticipantCollectionViewCell ?? ScheduleParticipantCollectionViewCell()
      
      let model = data.participants[indexPath.row]
      let participantCount = data.participants.count
      let isMoreCell = participantCount > 7 && indexPath.row == 6 ? true : false
      
      cell.configureUI(
        with: .init(
          name: model.nickname,
          imageName: model.profileImage
        ),
        type: isMoreCell ? .moreParticipant(participantCount - 7) : .participant
      )
      return cell
    case .multiLine:
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ParticipantCollectionViewCell.identifier, for: indexPath) as? ParticipantCollectionViewCell ?? ParticipantCollectionViewCell()
      let model = data.participants[indexPath.row]
      cell.configureUI(with:
          .init(
            name: model.nickname,
            imageName: model.profileImage
          )
      )
      return cell
    }
  }
}

extension ScheduleParticipantViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    switch participantListType {
    case .oneLine:
      return CGSize(width: 40, height: 40)
    case .multiLine:
      return CGSize(width: 73, height: 73)
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    switch participantListType {
    case .oneLine:
      return 8
    case .multiLine:
      return 12
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    switch participantListType {
    case .oneLine:
      return 8
    case .multiLine:
      return 16
    }
  }
}
