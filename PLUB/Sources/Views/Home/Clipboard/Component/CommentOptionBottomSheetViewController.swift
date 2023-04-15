//
//  CommentOptionBottomSheetViewController.swift
//  PLUB
//
//  Created by 홍승현 on 2023/04/15.
//

import UIKit

final class CommentOptionBottomSheetViewController: BottomSheetViewController {
  
  enum AccessType {
    case host
    case author
    case normal
  }
  
  
  
  // MARK: - Initializations
  
  init(accessType: AccessType) {
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
