//
//  LocationBaseView.swift
//  PLUB
//
//  Created by 김수빈 on 2023/01/22.
//
import UIKit

import SnapKit

final class LocationBaseView: UIView {
  private let contentView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 32
  }
  
  private let beforeSearchImage = UIImageView().then {
    $0.image = UIImage(named: "beforeSearch")
    $0.contentMode = .scaleAspectFit
  }
  
  private let titleLabel = UILabel().then {
    $0.text = "장소 또는 지역을 검색해주세요."
    $0.textColor = .black
    $0.font = .subtitle
    $0.textAlignment = .center
  }
  
  private let subtitleLabel = UILabel().then {
    $0.text = "예) 마포구, 강남역, 광화문 광장 등"
    $0.textColor = .deepGray
    $0.font = .caption
    $0.textAlignment = .center
  }
  
  init() {
    super.init(frame: .zero)
    setupLayouts()
    setupConstraints()
  }
  
  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupLayouts() {
    addSubview(contentView)
    
    [beforeSearchImage, titleLabel, subtitleLabel].forEach {
      contentView.addArrangedSubview($0)
    }
  }
  
  private func setupConstraints() {
    contentView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
    
    beforeSearchImage.snp.makeConstraints {
      $0.height.equalTo(136.23)
    }
    
    titleLabel.snp.makeConstraints {
      $0.height.equalTo(19)
    }
    
    subtitleLabel.snp.makeConstraints {
      $0.height.equalTo(16)
    }
    
    contentView.setCustomSpacing(8, after: titleLabel)
  }
}
