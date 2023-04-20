//
//  EditApplicationViewController.swift
//  PLUB
//
//  Created by 김수빈 on 2023/04/19.
//

import UIKit

protocol EditApplicationDelegate: AnyObject {
  func editApplication()
}

final class EditApplicationViewController: BaseViewController {
  private var answers: [Answer]
  let viewModel: EditApplicationViewModel
  weak var delegate: EditApplicationDelegate?
  
  private let scrollView = UIScrollView().then {
    $0.bounces = false
    $0.showsVerticalScrollIndicator = false
  }
  
  private let contentStackView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 16
  }
  
  private let editButton = UIButton(configuration: .plain()).then {
    $0.configurationUpdateHandler = $0.configuration?.plubButton(label: "수정하기")
  }
  
  private let tapGesture = UITapGestureRecognizer(
    target: EditApplicationViewController.self,
      action: nil
  ).then {
    $0.numberOfTapsRequired = 1
    $0.cancelsTouchesInView = false
    $0.isEnabled = true
  }
  
  init(plubbingID: Int, answers: [Answer]) {
    self.answers = answers
    self.viewModel = EditApplicationViewModel(plubbingID: plubbingID)
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    [scrollView, editButton].forEach {
      view.addSubview($0)
    }
    
    scrollView.addSubview(contentStackView)
    
    answers.enumerated().forEach { (index, answer) in
      let textView = InputTextView(title: answer.question, placeHolder: "")
      textView.setText(text: answer.answer)
      contentStackView.addArrangedSubview(textView)
      
      textView.rx.text
        .orEmpty
        .distinctUntilChanged()
        .withUnretained(self)
        .subscribe(onNext: { owner, answerText in
          owner.answers[index].answer = answerText
          owner.viewModel.answerText.onNext(owner.answers)
        })
        .disposed(by: disposeBag)
    }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    scrollView.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide)
      $0.leading.trailing.bottom.equalToSuperview().inset(16)
    }
    
    contentStackView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
      $0.width.equalTo(scrollView.snp.width)
    }
    
    editButton.snp.makeConstraints {
      $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(26)
      $0.horizontalEdges.equalToSuperview().inset(16)
      $0.height.equalTo(46)
    }
  }
  
  override func setupStyles() {
    super.setupStyles()
    setupNavigationBar()
  }
  
  override func bind() {
    super.bind()
    
    viewModel.editButtonEnabled
      .drive(editButton.rx.isEnabled)
      .disposed(by: disposeBag)

    editButton.rx.tap
      .asDriver()
      .drive(viewModel.editButtonTapped)
      .disposed(by: disposeBag)
    
    viewModel.successEditApplication
      .drive(with: self) { owner, _ in
        owner.delegate?.editApplication()
        owner.navigationController?.popViewController(animated: true)
      }
      .disposed(by: disposeBag)
    
    tapGesture.rx.event
      .asDriver()
      .drive(onNext: { [weak self] _ in
        guard let self = self else { return }
        self.view.endEditing(true)
      })
      .disposed(by: disposeBag)
    
    scrollView.addGestureRecognizer(tapGesture)
  }
  
  private func setupNavigationBar() {
    navigationItem.leftBarButtonItem = UIBarButtonItem(
      image: UIImage(named: "backButton"),
      style: .plain,
      target: self,
      action: #selector(didTappedBackButton)
    )
  }
  
  @objc
  private func didTappedBackButton() {
    navigationController?.popViewController(animated: true)
  }
}
