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
  
  private let participantCollectionView = UICollectionView(
    frame: .zero,
    collectionViewLayout: UICollectionViewFlowLayout()
  ).then {
    $0.backgroundColor = .background
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    
  }
  
  override func bind() {
    super.bind()
    
    
  }
}
