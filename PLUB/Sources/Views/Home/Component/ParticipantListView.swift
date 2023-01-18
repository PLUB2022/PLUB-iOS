//
//  ParticipantListView.swift
//  PLUB
//
//  Created by 이건준 on 2023/01/18.
//

import UIKit

import SnapKit
import Then

protocol ParticipantListViewDelegate: AnyObject {
  func didTappedMoreButton()
}

class ParticipantListView: UIView {
  
  weak var delegate: ParticipantListViewDelegate?
  
  private let participantTitleLabel = UILabel().then {
    $0.textColor = .black
    $0.font = .h5
    $0.textAlignment = .justified
    $0.text = "With us!"
    $0.sizeToFit()
  }
  
  private lazy var participantListCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout().then({
    $0.minimumInteritemSpacing = 3
    $0.scrollDirection = .horizontal
  })).then {
    $0.backgroundColor = .background
    $0.isScrollEnabled = false
    $0.delegate = self
    $0.dataSource = self
    $0.register(ParticipantListCollectionViewCell.self, forCellWithReuseIdentifier: ParticipantListCollectionViewCell.identifier)
  }
  
  private let moreButton = UIButton().then {
    $0.backgroundColor = .lightGray
    $0.tintColor = .deepGray
    $0.layer.masksToBounds = true
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    let moreButtonSize = moreButton.frame.size
    moreButton.layer.cornerRadius = moreButtonSize.width / 2
  }
  
  private func configureUI() {
    [participantTitleLabel, participantListCollectionView, moreButton].forEach { addSubview($0) }
    
    participantTitleLabel.snp.makeConstraints {
      $0.top.left.equalToSuperview()
    }
    
    participantListCollectionView.snp.makeConstraints {
      $0.top.equalTo(participantTitleLabel.snp.bottom)
      $0.left.equalToSuperview()
      $0.bottom.equalToSuperview()
    }
    
    moreButton.snp.makeConstraints {
      $0.left.equalTo(participantListCollectionView.snp.right).offset(3)
      $0.centerY.equalTo(participantListCollectionView)
      $0.right.bottom.equalToSuperview()
      $0.width.height.equalTo(34)
    }
    
    moreButton.addTarget(self, action: #selector(didTappedMoreButton), for: .touchUpInside)
  }
  
  @objc private func didTappedMoreButton() {
    delegate?.didTappedMoreButton()
  }
}

extension ParticipantListView: UICollectionViewDelegate, UICollectionViewDataSource {
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return 10
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ParticipantListCollectionViewCell.identifier, for: indexPath) as? ParticipantListCollectionViewCell ?? ParticipantListCollectionViewCell()
    cell.configureUI(with: "")
    return cell
  }
}

extension ParticipantListView: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: 34, height: 34)
  }
}
