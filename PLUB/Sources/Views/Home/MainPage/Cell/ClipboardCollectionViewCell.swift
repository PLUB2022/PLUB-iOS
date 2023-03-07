//
//  ClipboardCollectionViewCell.swift
//  PLUB
//
//  Created by 이건준 on 2023/03/07.
//

import UIKit

import SnapKit
import Then

struct ClipboardCollectionViewCellModel {
  let contentImageString: String?
  let contentText: String?
}

class ClipboardCollectionViewCell: UICollectionViewCell {
  
  static let identifier = "ClipboardCollectionViewCell"
  
  var type: PostType? {
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
      contentView.addSubview(contentLabel)
      contentLabel.snp.makeConstraints {
        $0.directionalEdges.equalToSuperview()
      }
    default:
      contentView.addSubview(contentImageView)
      contentImageView.snp.makeConstraints {
        $0.directionalEdges.equalToSuperview()
      }
    }
  }
  
  func configureUI(with model: ClipboardCollectionViewCellModel) {
    guard let type = type else { return }
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
