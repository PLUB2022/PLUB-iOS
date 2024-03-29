//
//  RegisterInterestViewController.swift
//  PLUB
//
//  Created by 이건준 on 2022/10/07.
//

import UIKit

import RxSwift
import RxCocoa
import SnapKit
import Then

final class RegisterInterestViewController: BaseViewController {
  
  private let viewModel: RegisterInterestViewModelType
  
  private var registerInterestModels: [RegisterInterestModel] = [] {
    didSet {
      registerTableView.reloadData()
    }
  }
  
  private let registerInterestHeaderView = RegisterInterestHeaderView()
  
  private lazy var registerTableView = UITableView(frame: .zero, style: .grouped).then {
    $0.separatorStyle = .none
    $0.backgroundColor = .secondarySystemBackground
    $0.sectionHeaderHeight = .leastNonzeroMagnitude
    $0.sectionFooterHeight = .leastNonzeroMagnitude
    $0.showsVerticalScrollIndicator = false
    $0.register(RegisterInterestTableViewCell.self, forCellReuseIdentifier: RegisterInterestTableViewCell.identifier)
    $0.register(RegisterInterestDetailTableViewCell.self, forCellReuseIdentifier: RegisterInterestDetailTableViewCell.identifier)
  }
  
  private let floatingButton = UIButton().then {
    $0.backgroundColor = .main
    $0.setTitle("다음", for: .normal)
    $0.setTitleColor(.white, for: .normal)
    $0.layer.masksToBounds = true
    $0.layer.cornerRadius = 10
    
  }
  
  init(viewModel: RegisterInterestViewModelType) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
    registerTableView.rowHeight = UITableView.automaticDimension
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    [registerInterestHeaderView, registerTableView, floatingButton].forEach { view.addSubview($0) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    registerInterestHeaderView.snp.makeConstraints {
      $0.top.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
      $0.height.equalTo(100)
    }
    
    registerTableView.snp.makeConstraints {
      $0.top.equalTo(registerInterestHeaderView.snp.bottom).offset(20)
      $0.leading.trailing.bottom.equalToSuperview().inset(20)
    }
    
    floatingButton.snp.makeConstraints { 
      $0.leading.trailing.bottom.equalToSuperview().inset(20)
      $0.height.equalTo(60)
    }
  }
  
  override func setupStyles() {
    super.setupStyles()
  }
  
  override func bind() {
    super.bind()
    viewModel.fetchedRegisterInterest
      .drive(rx.registerInterestModels)
      .disposed(by: disposeBag)
    
    viewModel.isEnabledFloatingButton.asObservable()
      .withUnretained(self)
      .subscribe(onNext: { owner, isEnabled in
        owner.floatingButton.isEnabled = isEnabled
        owner.floatingButton.backgroundColor = isEnabled ? .main : .lightGray
        owner.floatingButton.setTitleColor(isEnabled ? .white : .darkGray, for: .normal)
      })
      .disposed(by: disposeBag)
    
    viewModel.successRegisterInterest
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        Log.debug("관심사 등록성공")
        owner.navigationController?.popViewController(animated: true)
      })
      .disposed(by: disposeBag)
    
    floatingButton.rx.tap
      .bind(to: viewModel.tappedRegisterButton)
      .disposed(by: disposeBag)
    
    
    registerTableView.rx.setDelegate(self).disposed(by: disposeBag)
    registerTableView.rx.setDataSource(self).disposed(by: disposeBag)
  }
}

extension RegisterInterestViewController: UITableViewDelegate, UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return registerInterestModels.count
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if registerInterestModels[section].isExpanded {
      return 2
    }
    return 1
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if indexPath.row == 0 {
      let cell = tableView.dequeueReusableCell(withIdentifier: RegisterInterestTableViewCell.identifier, for: indexPath) as? RegisterInterestTableViewCell ?? RegisterInterestTableViewCell()
      cell.configureUI(with: registerInterestModels[indexPath.section])
      cell.delegate = self
      return cell
    } else {
      let cell = tableView.dequeueReusableCell(withIdentifier: RegisterInterestDetailTableViewCell.identifier, for: indexPath) as? RegisterInterestDetailTableViewCell ?? RegisterInterestDetailTableViewCell()
      cell.configureUI(with: registerInterestModels[indexPath.section], indexPath: indexPath)
      cell.delegate = self
      return cell
    }
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    
    if indexPath.row == 0 {
      registerInterestModels[indexPath.section].isExpanded.toggle()
      tableView.reloadSections([indexPath.section], with: .none)
    }
  }
  
  func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
    return UITableView.automaticDimension
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    if indexPath.row == 0 {
      return 80
    }
    
    let valuable = ceil(CGFloat(registerInterestModels[indexPath.section].category.subCategories.count / 4))
    return (valuable + 1) * 32 + 16 + 16 + valuable * 8
  }
}

extension RegisterInterestViewController: RegisterInterestDetailTableViewCellDelegate {
  func didTappedInterestTypeCollectionViewCell(cell: InterestTypeCollectionViewCell, mainIndexPath: IndexPath, subIndexPath: IndexPath) {
    var category = registerInterestModels[mainIndexPath.section].category
    category.subCategories[subIndexPath.row].isSelected.toggle()
    cell.isTapped.toggle()
    cell.isTapped ? viewModel.selectDetailCell.onNext(category.id) : viewModel.deselectDetailCell.onNext(category.id)
  }
}

extension RegisterInterestViewController: RegisterInterestTableViewCellDelegate {
  func didTappedIndicatorButton(cell: RegisterInterestTableViewCell) {
    guard let indexPath = registerTableView.indexPath(for: cell) else { return }
    registerInterestModels[indexPath.section].isExpanded.toggle()
    registerTableView.reloadSections([indexPath.section], with: .none)
  }
}
