//
//  PhotoBottomSheet.swift
//  PLUB
//
//  Created by 김수빈 on 2023/01/17.
//

import UIKit

class PhotoBottomSheet: UIView {
  let backView = UIView().then {
    $0.backgroundColor = .init(hex: 0x000000)
    $0.alpha = 0.25
    $0.isUserInteractionEnabled = true
  }
  
  private let contentView = UIView().then {
    $0.backgroundColor = .background
    $0.layer.cornerRadius = 20
    $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
  }
  
  private let lineView = UIView().then {
    $0.backgroundColor = .mediumGray
    $0.layer.cornerRadius = 6
  }
  
  private let contentStackView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 8
    $0.backgroundColor = .background
  }
  
  private let cameraView = PhotoBottomSheetListView(
    text: "카메라로 촬영",
    image: "camera"
  )
  
  private let albumView = PhotoBottomSheetListView(
    text: "앨범에서 사진 업로드",
    image: "selectPhotoBlack"
  )
  
  init() {
    super.init(frame: .zero)
    setupLayouts()
    setupConstraints()
  }
  
  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupLayouts() {
    [backView, contentView, lineView, contentStackView].forEach {
      addSubview($0)
    }
    
    [cameraView, albumView].forEach {
      contentStackView.addArrangedSubview($0)
    }
  }
  
  private func setupConstraints() {
    backView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
    
    contentView.snp.makeConstraints {
      $0.leading.trailing.bottom.equalToSuperview()
    }
    
    lineView.snp.makeConstraints {
      $0.top.equalToSuperview().inset(8)
      $0.height.equalTo(4)
      $0.width.equalTo(48)
    }
    
    contentStackView.snp.makeConstraints {
      $0.top.equalTo(lineView.snp.bottom).offset(26)
      $0.leading.trailing.equalToSuperview().inset(24)
      $0.bottom.equalToSuperview().inset(78)
    }
    
    cameraView.snp.makeConstraints {
      $0.height.equalTo(52)
    }
    
    albumView.snp.makeConstraints {
      $0.height.equalTo(52)
    }
  }
}
