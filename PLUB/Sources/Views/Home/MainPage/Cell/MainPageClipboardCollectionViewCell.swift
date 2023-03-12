//
//  ClipboardCollectionViewCell.swift
//  PLUB
//
//  Created by 이건준 on 2023/03/07.
//

import UIKit

import SnapKit
import Then

enum MainPageClipboardType: Int, CaseIterable {
  case one = 1 // 클립보드한 내역이 하나인 경우
  case two // 클립보드한 내역이 2개인 경우
  case moreThanThree // 클립보드한 내역이 3개이상인 경우
}

struct MainPageClipboardViewModel {
  let type: PostType
  let contentImageString: String?
  let contentText: String?
}

final class MainPageClipboardView: UIView {
  
  private var type: PostType? {
    didSet {
      guard oldValue != type else { return }
      configureUI()
    }
  }
  
  private lazy var contentImageView = UIImageView().then {
    $0.contentMode = .scaleAspectFit
    $0.image = UIImage(systemName: "heart.fill")
  }
  
  private lazy var contentLabel = UILabel().then {
    $0.font = .body2
    $0.textColor = .black
    $0.text = "sdfsdfsafasfsdfsdafsdafasfsafsafdsadfasdfs"
    $0.numberOfLines = 3
    $0.lineBreakMode = .byTruncatingTail
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    guard let type = type else { return }
    switch type {
    case .text:
      addSubview(contentLabel)
      contentLabel.snp.makeConstraints {
        $0.directionalEdges.equalToSuperview()
      }
    default:
      addSubview(contentImageView)
      contentImageView.snp.makeConstraints {
        $0.directionalEdges.equalToSuperview()
      }
    }
  }
  
  func configureUI(with model: MainPageClipboardViewModel) {
    self.type = model.type
    switch type {
    case .text:
      guard let contentText = model.contentText else { return }
      contentLabel.text = contentText
    default:
      guard let contentImage = model.contentImageString,
            let imageURL = URL(string: contentImage) else { return }
      contentImageView.kf.setImage(with: imageURL)
    }
  }
}
