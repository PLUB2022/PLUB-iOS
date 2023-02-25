//
//  ParticipantStackView.swift
//  PLUB
//
//  Created by 김수빈 on 2023/02/25.
//

import UIKit

final class participantStackView: UIStackView {
  let imageView = UIImageView().then {
    $0.layer.cornerRadius = 12
    $0.layer.borderWidth = 1
    $0.layer.borderColor = UIColor.white.cgColor
    $0.clipsToBounds = true
  }
}
