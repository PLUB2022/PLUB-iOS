//
//  ClipboardCollectionViewCell.swift
//  PLUB
//
//  Created by 이건준 on 2023/03/07.
//

import UIKit

import SnapKit
import Then

enum MainPageClipboardType {
  case one // 클립보드한 내역이 하나인 경우
  case two // 클립보드한 내역이 2개인 경우
  case moreThanThree // 클립보드한 내역이 3개이상인 경우
  
  static func getMainPageClipboardType(with model: [MainPageClipboardViewModel]) -> Self {
    if model.count == 1 {
      return .one
    }
    else if model.count == 2 {
      return .two
    }
    else {
      return .moreThanThree
    }
  }
}

struct MainPageClipboardViewModel {
  let type: PostType
  let contentImageString: String?
  let contentText: String?
  
  init(type: PostType, contentImageString: String?, contentText: String?) {
    self.type = type
    self.contentImageString = contentImageString
    self.contentText = contentText
  }
  
  init(model: BoardModel) {
    type = model.type
    contentImageString = model.imageLink
    contentText = model.content
  }
}

final class MainPageClipboardView: UIView {
  
  private var type: PostType? {
    didSet {
      guard oldValue != type else { return }
      configureUI()
    }
  }
  
  private lazy var contentImageView = UIImageView().then {
    $0.contentMode = .scaleAspectFill
  }
  
  private lazy var contentLabel = PaddingLabel(withInsets: 10, 10, 8, 8).then {
    $0.font = .body2
    $0.textColor = .black
    $0.numberOfLines = 0
    $0.lineBreakMode = .byTruncatingTail
    $0.textAlignment = .left
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
        $0.top.directionalHorizontalEdges.equalToSuperview()
        $0.bottom.lessThanOrEqualToSuperview()
      }
      backgroundColor = .subMain
    default:
      addSubview(contentImageView)
      contentImageView.snp.makeConstraints {
        $0.directionalEdges.equalToSuperview()
      }
    }
    layer.masksToBounds = true
    layer.cornerRadius = 10
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
