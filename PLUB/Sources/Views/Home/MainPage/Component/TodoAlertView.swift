//
//  TodoAlertButton.swift
//  PLUB
//
//  Created by 이건준 on 2023/03/31.
//

import UIKit

import SnapKit
import Then

final class TodoAlertView: UIView {
  
  private let containerImageView = UIImageView().then {
    $0.backgroundColor = .clear
  }
  
  private let addPhotoImageView = UIImageView().then {
    $0.image = UIImage(named: "selectPhotoBlack")
  }
  
  private let addPhotoLabel = UILabel().then {
    $0.text = "내가 이룬것을 사진으로 자랑해보세요!"
    $0.font = .caption2
    $0.textColor = .black
  }
  
  let button = UIButton()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }
  
  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    isUserInteractionEnabled = true
    backgroundColor = .lightGray
    layer.masksToBounds = true
    layer.cornerRadius = 8
    
    [addPhotoImageView, addPhotoLabel, containerImageView, button].forEach { addSubview($0) }
    addPhotoImageView.snp.makeConstraints {
      $0.size.equalTo(44)
      $0.centerX.equalToSuperview()
      $0.top.equalToSuperview().inset(62)
    }
    
    addPhotoLabel.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.top.equalTo(addPhotoImageView.snp.bottom).offset(10)
    }
    
    containerImageView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
    
    button.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
  }
  
  func configureUI(with model: UIImage) {
    containerImageView.image = model
  }
}
