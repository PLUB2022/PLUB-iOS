//
//  InputTextView.swift
//  PLUB
//
//  Created by 김수빈 on 2023/01/08.
//

import SnapKit
import UIKit
import RxSwift

final class InputTextView: UIView {
  
  // MARK: - Property
  private let disposeBag = DisposeBag()
  
  private let placeHolder: String
  private let totalCharacterLimit: Int?
  
  private let stackView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 8
  }
  
  private let titleView = UIView()
  
  private let titleLabel = UILabel().then {
    $0.font = .subtitle
  }
  
  private let questionButton = UIButton().then {
    $0.setImage(UIImage(named: "questionButton"), for: .normal)
  }
  
  private let textView = UITextView().then {
    $0.textColor = .deepGray
    $0.textContainerInset = UIEdgeInsets(
      top: 11,
      left: 8,
      bottom: 11,
      right: 8
    )
    $0.font = .body2
    $0.backgroundColor = .white
    $0.layer.cornerRadius = 8
    $0.isScrollEnabled = false
  }
  
  private let countTextLabel = UILabel().then {
    $0.font = .overLine
    $0.textAlignment = .right
  }
  
  init(
    title: String,
    placeHolder: String,
    option: InputTextOption = InputTextOption(
      textCount: false,
      questionOption: false
    ),
    totalCharacterLimit: Int? = nil
  ) {
    self.placeHolder = placeHolder
    self.totalCharacterLimit = totalCharacterLimit
    
    super.init(frame: .zero)
    
    titleLabel.text = title
    textView.text = placeHolder
    setupLayouts(option: option)
    setupConstraints(option: option)
    setupStyles()
    bind()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupLayouts(option: InputTextOption) {
    addSubview(stackView)
    
    let stackViewSubviews = [
      titleView,
      textView,
      option.textCount ? countTextLabel : nil
    ].compactMap { $0 }
    
    stackViewSubviews.forEach {
      stackView.addArrangedSubview($0)
    }
    
    let titleStackViewSubviews = [
      titleLabel,
      option.questionOption ? questionButton : nil
    ].compactMap { $0 }
    
    titleStackViewSubviews.forEach {
      titleView.addSubview($0)
    }
  }
  
  private func setupConstraints(option: InputTextOption) {
    stackView.snp.makeConstraints{
      $0.top.bottom.equalToSuperview()
      $0.leading.trailing.equalToSuperview().inset(16)
    }
    
    titleView.snp.makeConstraints {
      $0.height.equalTo(19)
    }
    
    titleLabel.snp.makeConstraints {
      $0.centerY.equalToSuperview()
      $0.leading.equalToSuperview()
    }
    
    if option.questionOption {
      questionButton.snp.makeConstraints {
        $0.size.equalTo(12)
        $0.centerY.equalTo(titleLabel.snp.centerY)
        $0.leading.equalTo(titleLabel.snp.trailing).offset(6)
      }
    }
    
    textView.snp.makeConstraints {
      $0.height.equalTo(46)
    }
    
    if option.textCount {
      countTextLabel.snp.makeConstraints {
        $0.height.equalTo(12)
      }
      stackView.setCustomSpacing(4, after: textView)
    }
  }
  
  private func setupStyles() {
    updateWrittenCharactersLabel(count: 0, pointColor: .mediumGray)
  }
  
  private func bind(){
    textView.rx.didBeginEditing
      .subscribe(onNext: { [weak self] in
        guard let self = self else { return }
        if(self.textView.text == self.placeHolder &&
           self.textView.textColor == .deepGray){
          self.textView.text = ""
          self.textView.textColor = .black
        }
      }
    ).disposed(by: disposeBag)
    
    textView.rx.didEndEditing
      .subscribe(onNext: { [weak self] in
        guard let self = self else { return }
        if self.textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
            self.textView.textColor == .black {
          self.updateWrittenCharactersLabel(count: 0, pointColor: .mediumGray)
          self.textView.text = self.placeHolder
          self.textView.textColor = .deepGray
        }
        
        self.updateTextViewHeightAutomatically()
      }
    ).disposed(by: disposeBag)
  
    textView.rx.text
      .asDriver()
      .drive (onNext: { [weak self] in
        guard let self = self else { return }
        self.updateTextViewHeightAutomatically()
        
        guard $0 != self.placeHolder,
                let text = $0 else { return }
        
        let color: UIColor = self.textView.text.count == 0 ? .mediumGray : .black
        self.updateWrittenCharactersLabel(count: self.textView.text.count, pointColor: color)
        
        guard let maxTextCount = self.totalCharacterLimit else { return }
        
        guard text.count > maxTextCount else { return }
        let index = text.index(text.startIndex, offsetBy: maxTextCount)
        self.textView.text = String(text[..<index])
      }
    ).disposed(by: disposeBag)
  }
}

// MARK: - Function

extension InputTextView {
  private func updateTextViewHeightAutomatically() {
    let size = CGSize(
      width: textView.frame.width,
      height: .infinity
    )
    let estimatedSize = textView.sizeThatFits(size)
    
    textView.snp.updateConstraints {
      $0.height.equalTo(estimatedSize.height)
    }
  }
  
  private func updateWrittenCharactersLabel(
    count: Int,
    pointColor: UIColor
  ) {
    let writtenCharacters = NSAttributedString(
      string: "\(count)",
      attributes: [.foregroundColor: pointColor]
    )
    
    let totalCharacters = NSAttributedString(
      string: "/\(totalCharacterLimit ?? 0)",
      attributes: [.foregroundColor: UIColor.deepGray]
    )
    
    countTextLabel.attributedText = NSMutableAttributedString(attributedString: writtenCharacters).then {
      $0.append(totalCharacters)
    }
  }
}

struct InputTextOption {
  let textCount: Bool // 글자수 세기
  let questionOption: Bool // 물음표 버튼
}
