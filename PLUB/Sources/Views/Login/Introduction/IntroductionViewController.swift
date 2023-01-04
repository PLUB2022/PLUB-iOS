//
//  IntroductionViewController.swift
//  PLUB
//
//  Created by 홍승현 on 2023/01/04.
//

import UIKit

import SnapKit
import Then

final class IntroductionViewController: BaseViewController {
  
  // MARK: - Property
  
  private let stackView: UIStackView = UIStackView().then {
    $0.axis = .vertical
  }
  
  private let introductionLabel: UILabel = UILabel().then {
    $0.text = "소개"
    $0.font = .subtitle
  }
  
  private lazy var introductionTextView: UITextView = UITextView().then {
    $0.text = placeHolder
    $0.textColor = .deepGray
    $0.textContainerInset = UIEdgeInsets(top: 14, left: 8, bottom: 14, right: 8)
    $0.font = .body2
    
    $0.backgroundColor = .white
    $0.layer.cornerRadius = 8
    
    $0.delegate = self
  }
  
  private let overlineLabel: UILabel = UILabel().then {
    $0.font = .overLine

    let writtenCharacters = NSAttributedString(string: "0", attributes: [.foregroundColor: UIColor.mediumGray])
    let totalCharacters = NSAttributedString(string: "/150", attributes: [.foregroundColor: UIColor.deepGray])
    $0.attributedText = NSMutableAttributedString(attributedString: writtenCharacters).then {
      $0.append(totalCharacters)
    }
  }
  
  // MARK: - Configuration
  
  override func setupLayouts() {
    super.setupLayouts()
    view.addSubview(stackView)
    view.addSubview(overlineLabel)
    
    [introductionLabel, introductionTextView].forEach {
      stackView.addArrangedSubview($0)
    }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    stackView.snp.makeConstraints { make in
      make.top.horizontalEdges.equalToSuperview()
    }
    
    introductionTextView.snp.makeConstraints { make in
      make.height.equalTo(46)
    }
    
    overlineLabel.snp.makeConstraints { make in
      make.top.equalTo(stackView.snp.bottom).offset(4)
      make.trailing.equalToSuperview()
    }
  }
  
  override func bind() {
    super.bind()
  }
  
  // MARK: - First Responder
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    introductionTextView.resignFirstResponder()
  }
}

// MARK: - Constants

extension IntroductionViewController {
  private var placeHolder: String {
    return "소개하는 내용을 입력해주세요"
  }
}

// MARK: - UITextViewDelegate

extension IntroductionViewController: UITextViewDelegate {
  func textViewDidEndEditing(_ textView: UITextView) {
    // text가 비어있으면서 글자색이 검정인 경우 -> 사용자가 입력 후 다 지운 경우
    if textView.text.isEmpty && textView.textColor == .black {
      textView.text = placeHolder
      textView.textColor = .deepGray
    }
  }
  
  func textViewDidBeginEditing(_ textView: UITextView) {
    // text가 지정된 placeholder면서 글자색이 짙은회색인 경우
    // 즉 placeholder을 띄운 상태인데 사용자가 수정하려고 textview를 누른 경우
    if textView.text == placeHolder && textView.textColor == .deepGray {
      textView.text = ""
      textView.textColor = .black
    }
  }
}


#if canImport(SwiftUI) && DEBUG
import SwiftUI
struct IntroductionViewControllerPreview: PreviewProvider {
  static var previews: some View {
    IntroductionViewController().toPreview()
  }
}
#endif

