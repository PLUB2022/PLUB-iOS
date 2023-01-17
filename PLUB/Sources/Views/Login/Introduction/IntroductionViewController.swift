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
    $0.spacing = 8
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
    
    $0.isScrollEnabled = false
    $0.delegate = self
  }
  
  private let overlineLabel: UILabel = UILabel().then {
    $0.font = .overLine
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
    stackView.snp.makeConstraints {
      $0.top.horizontalEdges.equalToSuperview()
    }
    
    introductionTextView.snp.makeConstraints {
      $0.height.equalTo(46)
    }
    
    overlineLabel.snp.makeConstraints {
      $0.top.equalTo(stackView.snp.bottom).offset(4)
      $0.trailing.equalToSuperview()
    }
  }
  
  override func setupStyles() {
    super.setupStyles()
    updateWrittenCharactersLabel(count: 0, pointColor: .mediumGray)
  }
  
  private func updateWrittenCharactersLabel(count: Int, pointColor: UIColor) {
    let writtenCharacters = NSAttributedString(string: "\(count)", attributes: [.foregroundColor: pointColor])
    let totalCharacters = NSAttributedString(string: "/\(totalCharacterLimit)", attributes: [.foregroundColor: UIColor.deepGray])
    overlineLabel.attributedText = NSMutableAttributedString(attributedString: writtenCharacters).then {
      $0.append(totalCharacters)
    }
  }
  
  private func updateTextViewHeightAutomatically(_ textView: UITextView) {
    // == textView dynamic height settings ==
    let size = CGSize(width: view.frame.width, height: .infinity)
    let estimatedSize = textView.sizeThatFits(size)
    
    // update height constraints
    textView.snp.updateConstraints {
      $0.height.equalTo(estimatedSize.height)
    }
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
  
  private var totalCharacterLimit: Int {
    return 150
  }
}

// MARK: - UITextViewDelegate

extension IntroductionViewController: UITextViewDelegate {
  func textViewDidEndEditing(_ textView: UITextView) {
    // text가 비어있으면서 글자색이 검정인 경우 -> 사용자가 입력 후 다 지운 경우
    if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && textView.textColor == .black {
      updateWrittenCharactersLabel(count: 0, pointColor: .mediumGray)
      textView.text = placeHolder
      textView.textColor = .deepGray
    }
    
    // == textView dynamic height settings ==
    updateTextViewHeightAutomatically(textView)
  }
  
  func textViewDidBeginEditing(_ textView: UITextView) {
    // text가 지정된 placeholder면서 글자색이 짙은회색인 경우
    // 즉 placeholder을 띄운 상태인데 사용자가 수정하려고 textview를 누른 경우
    if textView.text == placeHolder && textView.textColor == .deepGray {
      textView.text = ""
      textView.textColor = .black
    }
  }
  
  func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    // if the user presses the delete key, the length of the range is 1.
    if range.length == 1 { return true }
    return textView.text.count < totalCharacterLimit ? true : false
  }
  
  func textViewDidChange(_ textView: UITextView) {
    // == textView dynamic height settings ==
    updateTextViewHeightAutomatically(textView)
    
    // == overline label settings ==
    let color: UIColor =  introductionTextView.text.count == 0 ? .mediumGray : .black
    updateWrittenCharactersLabel(count: introductionTextView.text.count, pointColor: color)
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
