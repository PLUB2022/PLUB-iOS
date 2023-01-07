//
//  RegisterInterestViewController.swift
//  PLUB
//
//  Created by 이건준 on 2022/10/07.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

class RegisterInterestViewController: BaseViewController {
  
  private let viewModel: RegisterInterestViewModelType
  
  private var registerInterestModels: [RegisterInterestModel] = []
  
  private lazy var registerTableView = UITableView(frame: .zero, style: .grouped).then {
    $0.separatorStyle = .none
    $0.backgroundColor = .secondarySystemBackground
    $0.sectionFooterHeight = .leastNonzeroMagnitude
    $0.register(RegisterInterestTableViewCell.self, forCellReuseIdentifier: RegisterInterestTableViewCell.identifier)
    $0.register(RegisterInterestHeaderView.self, forHeaderFooterViewReuseIdentifier: RegisterInterestHeaderView.identifier)
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
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func setupLayouts() {
    _ = [registerTableView, floatingButton].map{ view.addSubview($0) }
  }
  
  override func setupConstraints() {
    registerTableView.snp.makeConstraints {
      $0.edges.equalToSuperview().inset(20)
    }
    
    floatingButton.snp.makeConstraints { 
      $0.left.right.bottom.equalToSuperview().inset(20)
      $0.height.equalTo(60)
    }
  }
  
  override func setupStyles() {
    view.backgroundColor = .secondarySystemBackground
    self.navigationItem.leftBarButtonItem = UIBarButtonItem(
      image: UIImage(systemName: "chevron.backward", withConfiguration: UIImage.SymbolConfiguration(hierarchicalColor: .black)),
      style: .done,
      target: self,
      action: #selector(didTappedLeftButton)
    )
  }
  
  override func bind() {
    viewModel.registerInterestFetched
      .drive(onNext: { [weak self] registerInterestModels in
        guard let `self` = self else { return }
        self.registerInterestModels = registerInterestModels
        self.registerTableView.reloadData()
      })
      .disposed(by: disposeBag)
    
    viewModel.isEnabledFloatingButton
      .drive(onNext: { [weak self] isEnabled in
        guard let `self` = self else { return }
        self.floatingButton.isEnabled = isEnabled
        self.floatingButton.backgroundColor = isEnabled ? .main : .lightGray
        self.floatingButton.setTitleColor(isEnabled ? .white : .darkGray, for: .normal)
      })
      .disposed(by: disposeBag)
    
    floatingButton.rx.tap
      .subscribe(onNext: { _ in
        
      })
      .disposed(by: disposeBag)
    
    
    registerTableView.rx.setDelegate(self).disposed(by: disposeBag)
    registerTableView.rx.setDataSource(self).disposed(by: disposeBag)
  }
  
  @objc private func didTappedLeftButton() {
    self.navigationController?.popViewController(animated: true)
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
    if indexPath.row == 1 {
      let cell = tableView.dequeueReusableCell(withIdentifier: RegisterInterestDetailTableViewCell.identifier, for: indexPath) as? RegisterInterestDetailTableViewCell ?? RegisterInterestDetailTableViewCell()
      let registerInterestModel = registerInterestModels[indexPath.section]
      cell.configureUI(with: registerInterestModel)
      cell.delegate = self
      return cell
    } else {
      let cell = tableView.dequeueReusableCell(withIdentifier: RegisterInterestTableViewCell.identifier, for: indexPath) as? RegisterInterestTableViewCell ?? RegisterInterestTableViewCell()
      let registerInterstModel = registerInterestModels[indexPath.section]
      let registerInterestTableViewCellModel = RegisterInterestTableViewCellModel(
        imageName: registerInterstModel.interestCollectionSectionType.imageNamed,
        title: registerInterstModel.interestCollectionSectionType.title,
        description: "PLUB! 에게 관심사를 선택해주세요",
        isExpanded: registerInterstModel.isExpanded
      )
      cell.configureUI(with: registerInterestTableViewCellModel)
      return cell
    }
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    if section == 0 {
      let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: RegisterInterestHeaderView.identifier) as? RegisterInterestHeaderView ?? RegisterInterestHeaderView()
      let registerInterestHeaderViewModel = RegisterInterestHeaderViewModel(
        title: "취미모임 관심사 등록",
        description: "PLUB 에게 당신의 관심사를 알려주세요.\n관심사 위주로 모임을 추천해 드려요!"
      )
      header.configureUI(with: registerInterestHeaderViewModel)
      return header
    }
    return UIView(frame: .zero)
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    if section != 0 {
      return .leastNonzeroMagnitude
    }
    return 150
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
    if indexPath.row == 1 {
      return 202
    }
    return 80
  }
}

extension RegisterInterestViewController: RegisterInterestDetailTableViewCellDelegate {
  func didTappedInterestTypeCollectionViewCell(cell: InterestTypeCollectionViewCell) {
    cell.isTapped.toggle()
    cell.isTapped ? viewModel.selectDetailCell.onNext(()) : viewModel.deselectDetailCell.onNext(())
  }
}
