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
    [participantCollectionView].forEach { contentView.addSubview($0) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    participantCollectionView.snp.makeConstraints {
      $0.edges.equalToSuperview()
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
