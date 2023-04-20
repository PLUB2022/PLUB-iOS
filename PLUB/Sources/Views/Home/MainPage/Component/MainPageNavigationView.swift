//
//  MainPageNavigationView.swift
//  PLUB
//
//  Created by 이건준 on 2023/03/03.
//

import UIKit

import SnapKit
import Then

protocol MainPageNavigationViewDelegate: AnyObject {
  func didTappedArchiveButton()
}

final class MainPageNavigationView: UIStackView {
  
  weak var delegate: MainPageNavigationViewDelegate?
  
  private let speakerBlack = UIButton().then {
    $0.setImage(UIImage(named: "speakerBlack"), for: .normal)
  }
  
  private let archiveButton = UIButton().then {
    $0.setImage(UIImage(named: "photoStackBlack"), for: .normal)
    $0.addTarget(MainPageNavigationView.self, action: #selector(didTappedArchiveButton), for: .touchUpInside)
  }
  
  private let verticalEllipsisBlack = UIButton().then {
    $0.setImage(UIImage(named: "verticalEllipsisBlack"), for: .normal)
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }
  
  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    [speakerBlack, archiveButton, verticalEllipsisBlack].forEach { addArrangedSubview($0) }
  }
  
  @objc private func didTappedArchiveButton() {
    delegate?.didTappedArchiveButton()
  }
}
