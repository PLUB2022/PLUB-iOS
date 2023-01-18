//
//  PhotoSelectView.swift
//  PLUB
//
//  Created by 김수빈 on 2023/01/15.
//

import UIKit

import SnapKit

final class PhotoSelectView: UIView {
  private let selectView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 8
  }
  
  private let selectLabel = UILabel().then {
    $0.text = "사진 추가하기"
    $0.textColor = .darkGray
    $0.font = .button
  }
  
  private let selectImage = UIImageView().then {
    $0.image = UIImage(named: "selectPhoto")
    $0.contentMode = .scaleAspectFit
  }
  
  let selectedImage = UIImageView()
  
  let selectButton = UIButton().then {
    $0.backgroundColor = .clear
  }

  
  init() {
    super.init(frame: .zero)
    setupLayouts()
    setupConstraints()
    setupStyles()
  }
  
  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupLayouts() {
    [selectView, selectedImage, selectButton].forEach {
      addSubview($0)
    }

    [selectImage, selectLabel].forEach {
      selectView.addArrangedSubview($0)
    }
  }
  
  private func setupConstraints() {
    selectView.snp.makeConstraints {
      $0.center.equalToSuperview()
      $0.width.equalTo(selectLabel.intrinsicContentSize.width)
    }
    
    selectedImage.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
    
    selectButton.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
    
    selectImage.snp.makeConstraints {
      $0.size.equalTo(35)
    }
    
    selectLabel.snp.makeConstraints {
      $0.height.equalTo(16)
    }
  }
  
  private func setupStyles() {
    layer.cornerRadius = 6
    backgroundColor = .lightGray
  }
}
