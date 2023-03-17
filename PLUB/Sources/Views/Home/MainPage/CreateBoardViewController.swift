//
//  CreateBoardViewController.swift
//  PLUB
//
//  Created by 이건준 on 2023/03/17.
//

import UIKit

import SnapKit
import Then

final class CreateBoardViewController: BaseViewController {
  
  private let boardTypeLabel = UILabel().then {
    $0.textColor = .black
  }
  
  private let photoButton: UIButton = UIButton(configuration: .plain()).then {
    $0.configurationUpdateHandler = $0.configuration?.list(label: "사진 Only")
    $0.isSelected = true
  }
  
  private let textButton = UIButton(configuration: .plain()).then {
    $0.configurationUpdateHandler = $0.configuration?.list(label: "글 Only")
  }
  
  private let photoAndTextButton: UIButton = UIButton(configuration: .plain()).then {
    $0.configurationUpdateHandler = $0.configuration?.list(label: "사진+글")
  }
  
  private let titleLabel = UILabel().then {
    $0.textColor = .black
  }

  private let photoAddLabel = UILabel().then {
    $0.textColor = .black
  }
  
  override func setupStyles() {
    super.setupStyles()

    self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "back"), style: .plain, target: self, action: #selector(didTappedBackButton))
  }
  
  @objc private func didTappedBackButton() {
    self.navigationController?.popViewController(animated: true)
  }
  
}
