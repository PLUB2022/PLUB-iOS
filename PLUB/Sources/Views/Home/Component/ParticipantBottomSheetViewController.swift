//
//  ParticipantBottomSheetViewController.swift
//  PLUB
//
//  Created by 이건준 on 2023/02/14.
//

import UIKit

import SnapKit
import Then

final class ParticipantBottomSheetViewController: BottomSheetViewController {
  
  private let model: [AccountInfo]
  
  private let grabber = UIView().then {
    $0.backgroundColor = .mediumGray
    $0.layer.cornerRadius = 6
    $0.layer.masksToBounds = true
  }
  
  private let titleLabel = UILabel().then {
    $0.textColor = .black
    $0.font = .h5
    $0.text = "With us!"
  }
  
  private lazy var participantCollectionView = UICollectionView(
    frame: .zero,
    collectionViewLayout: UICollectionViewFlowLayout()
  ).then {
    $0.backgroundColor = .background
    $0.contentInset = UIEdgeInsets(top: 24, left: 16, bottom: 24, right: 16)
    $0.register(ParticipantCollectionViewCell.self, forCellWithReuseIdentifier: ParticipantCollectionViewCell.identifier)
    $0.delegate = self
    $0.dataSource = self
  }
  
  init(model: [AccountInfo]) {
    self.model = model
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    [grabber, titleLabel, participantCollectionView].forEach { contentView.addSubview($0) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    grabber.snp.makeConstraints {
      $0.top.equalToSuperview().inset(8)
      $0.centerX.equalToSuperview()
      $0.width.equalTo(48)
      $0.height.equalTo(4)
    }
    
    titleLabel.snp.makeConstraints {
      $0.top.equalTo(grabber.snp.bottom).offset(16)
      $0.leading.equalToSuperview().inset(16)
    }
    
    participantCollectionView.snp.makeConstraints {
      $0.top.equalTo(titleLabel.snp.bottom)
      $0.leading.trailing.equalToSuperview()
      $0.bottom.equalToSuperview()
      $0.height.equalTo(ceil(Double(model.count) / Double(4)) * (48 + 4 + 21) + (ceil(Double(model.count) / Double(4)) - 1) * 16 + Double(24 + 24))
      // (총 참여자 수 / 행 최대 인원 수) * (참여자프로필높이 + 프로필, 라벨 offset + 라벨높이) + ((총 참여자 수 / 행 최대 인원 수) - 1) * minimumLine + (topInset + bottomInset)
    }
  }
  
  override func setupStyles() {
    super.setupStyles()
    
  }
  
  override func bind() {
    super.bind()
  }
}

extension ParticipantBottomSheetViewController: UICollectionViewDelegate, UICollectionViewDataSource {
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return model.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ParticipantCollectionViewCell.identifier, for: indexPath) as? ParticipantCollectionViewCell ?? ParticipantCollectionViewCell()
    let model = model[indexPath.row]
    cell.configureUI(with: .init(name: model.nickname, imageName: model.profileImage ?? ""))
    return cell
  }
}

extension ParticipantBottomSheetViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: collectionView.frame.width / 4 - 16 - 3, height: 48 + 4 + 21)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 16
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return 12
  }
}
