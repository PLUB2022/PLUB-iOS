//
//  PhotoBottomSheetListView.swift
//  PLUB
//
//  Created by 김수빈 on 2023/01/17.
//

import UIKit

final class PhotoBottomSheetListView: UIView {
  private let imageView = UIImageView().then {
    $0.contentMode = .scaleAspectFit
  }
  
  private let label = UILabel().then {
    $0.font = .button
    $0.textColor = .black
  }
  
  let button = UIButton()

  init(
    text: String,
    image: String
  ) {
    super.init(frame: .zero)
    
    label.text = text
    imageView.image = UIImage(named: image)
    
    setupLayouts()
    setupConstraints()
    setupStyles()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupLayouts() {
    [imageView, label, button].forEach {
      addSubview($0)
    }
  }
  
  private func setupConstraints() {
    imageView.snp.makeConstraints {
      $0.centerY.equalToSuperview()
      $0.size.equalTo(24)
      $0.leading.equalToSuperview().inset(16)
    }
    
    label.snp.makeConstraints {
      $0.centerY.equalTo(imageView.snp.centerY)
      $0.leading.equalTo(imageView.snp.trailing).offset(8.67)
    }
    
    button.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
  }
  
  private func setupStyles() {
    layer.cornerRadius = 10
    layer.applyShadow(alpha: 0.10, x: 0, y: 0, blur: 5)
    backgroundColor = .white
  }
}
