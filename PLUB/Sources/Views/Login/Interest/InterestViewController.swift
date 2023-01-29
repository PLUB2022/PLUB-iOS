//
//  InterestViewController.swift
//  PLUB
//
//  Created by 홍승현 on 2023/01/23.
//

import UIKit

import RxCocoa
import RxSwift
import SnapKit
import Then

final class InterestViewController: BaseViewController {
  
  private let viewModel = InterestViewModel()
  
  weak var delegate: SignUpChildViewControllerDelegate?
  
  private var registerInterestModels: [RegisterInterestModel] = [] {
    didSet {
      tableView.reloadData()
    }
  }
  
  private lazy var tableView = UITableView(frame: .zero, style: .grouped).then {
    $0.separatorStyle = .none
    $0.backgroundColor = .secondarySystemBackground
    $0.sectionHeaderHeight = .leastNonzeroMagnitude
    $0.sectionFooterHeight = .leastNonzeroMagnitude
    $0.showsVerticalScrollIndicator = false
    $0.register(RegisterInterestTableViewCell.self, forCellReuseIdentifier: RegisterInterestTableViewCell.identifier)
    $0.register(RegisterInterestDetailTableViewCell.self, forCellReuseIdentifier: RegisterInterestDetailTableViewCell.identifier)
    $0.dataSource = self
    $0.delegate = self
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    view.addSubview(tableView)
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    tableView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
  }
  
  override func bind() {
    super.bind()
    
    viewModel.fetchData
      .drive(rx.registerInterestModels)
      .disposed(by: disposeBag)
    
    Driver.combineLatest(viewModel.isButtonEnabled, viewModel.selectedSubCategories)
      .drive(with: self, onNext: { owner, tuple in
        let flag = tuple.0
        let categories = tuple.1
        
        owner.delegate?.information(categories: categories) // 선택한 카테고리 전달
        owner.delegate?.checkValidation(index: 4, state: flag)  // 부모 뷰컨의 `확인 버튼` 활성화 처리
      })
      .disposed(by: disposeBag)
  }
}

// MARK: - UITableViewDataSource

extension InterestViewController: UITableViewDataSource {
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
}

// MARK: - UITableViewDelegate

extension InterestViewController: UITableViewDelegate {
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

// MARK: - RegisterInterestTableViewCellDelegate

extension InterestViewController: RegisterInterestTableViewCellDelegate {
  func didTappedIndicatorButton(cell: RegisterInterestTableViewCell) {
    guard let indexPath = tableView.indexPath(for: cell) else { return }
    registerInterestModels[indexPath.section].isExpanded.toggle()
    tableView.reloadSections([indexPath.section], with: .none)
  }
}

// MARK: - RegisterInterestDetailTableViewCellDelegate

extension InterestViewController: RegisterInterestDetailTableViewCellDelegate {
  func didTappedInterestTypeCollectionViewCell(cell: InterestTypeCollectionViewCell, mainIndexPath: IndexPath, subIndexPath: IndexPath) {
    registerInterestModels[mainIndexPath.section].category.subCategories[subIndexPath.row].isSelected.toggle()
    let id = registerInterestModels[mainIndexPath.section].category.subCategories[subIndexPath.row].id
    cell.isTapped.toggle()
    // 카테고리가 선택되거나 취소되었다면, 해당 카테고리의 id를 이용하여 emit
    cell.isTapped ? viewModel.selectSubCategory.onNext(id) : viewModel.deselectSubCategory.onNext(id)
  }
}
