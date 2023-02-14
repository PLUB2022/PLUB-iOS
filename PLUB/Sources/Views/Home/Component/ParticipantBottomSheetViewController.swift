//
//  ParticipantBottomSheetViewController.swift
//  PLUB
//
//  Created by 이건준 on 2023/02/14.
//

import UIKit

import SnapKit
import Then

class ParticipantBottomSheetViewController: BottomSheetViewController {
  
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
    $0.register(ParticipantCollectionViewCell.self, forCellWithReuseIdentifier: ParticipantCollectionViewCell.identifier)
    $0.delegate = self
    $0.dataSource = self
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
      $0.top.equalTo(titleLabel.snp.bottom).offset(24)
      $0.leading.trailing.bottom.equalToSuperview()
      $0.height.equalTo(251)
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
    return 10
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ParticipantCollectionViewCell.identifier, for: indexPath) as? ParticipantCollectionViewCell ?? ParticipantCollectionViewCell()
    cell.configureUI(with: .init(name: "이건준", imageName: ""))
    return cell
  }
}

extension ParticipantBottomSheetViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: 100, height: 48 + 21)
  }
}
