//
//  MeetingCategoryViewController.swift
//  PLUB
//
//  Created by 김수빈 on 2023/01/29.
//

import UIKit

import RxSwift
import SnapKit

final class MeetingCategoryViewController: BaseViewController {
  
  private var viewModel: MeetingCategoryViewModel
  weak var delegate: CreateMeetingChildViewControllerDelegate?
  private var childIndex: Int
  
  private var registerInterestModels: [RegisterInterestModel] = [] {
    didSet {
      tableView.reloadData()
    }
  }
  
  private lazy var categoryHeaderView = CategoryHeaderView()
  
  private lazy var tableView = UITableView(frame: .zero, style: .grouped).then {
    $0.separatorStyle = .none
    $0.backgroundColor = .secondarySystemBackground
    $0.tableHeaderView = categoryHeaderView
    $0.tableHeaderView?.frame.size.height = 90
    $0.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 56))
    $0.sectionHeaderHeight = .leastNonzeroMagnitude
    $0.sectionFooterHeight = .leastNonzeroMagnitude
    $0.showsVerticalScrollIndicator = false
    $0.register(RegisterInterestTableViewCell.self, forCellReuseIdentifier: RegisterInterestTableViewCell.identifier)
    $0.register(RegisterInterestDetailTableViewCell.self, forCellReuseIdentifier: RegisterInterestDetailTableViewCell.identifier)
  }
  
  init(
    viewModel: MeetingCategoryViewModel,
    childIndex: Int
  ) {
    self.viewModel = viewModel
    self.childIndex = childIndex
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    view.addSubview(tableView)
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    tableView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
  }
  
  override func setupStyles() {
    super.setupStyles()
    view.backgroundColor = .systemBackground
  }
  
  override func bind() {
    viewModel.fetchData
      .drive(rx.registerInterestModels)
      .disposed(by: disposeBag)
    
    viewModel.selectedSubCategoriesCount.asObservable()
      .withUnretained(self)
      .subscribe(onNext: { owner, count in
        owner.categoryHeaderView.updateSelectedCount(count: count)
      })
      .disposed(by: disposeBag)
    
    viewModel.isButtonEnabled.asObservable()
      .withUnretained(self)
      .subscribe(onNext: { owner, isEnabled in
        owner.delegate?.checkValidation(
          index: owner.childIndex,
          state: isEnabled
        )
      })
      .disposed(by: disposeBag)
    
    tableView.rx.setDelegate(self).disposed(by: disposeBag)
    tableView.rx.setDataSource(self).disposed(by: disposeBag)
  }
}

extension MeetingCategoryViewController: UITableViewDelegate, UITableViewDataSource {
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
      cell.configureUI(with: registerInterestModels[indexPath.section], indexPath: indexPath, selectEnabled: viewModel.selectEnabled)
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

extension MeetingCategoryViewController: RegisterInterestDetailTableViewCellDelegate {
  func didTappedInterestTypeCollectionViewCell(cell: InterestTypeCollectionViewCell, mainIndexPath: IndexPath, subIndexPath: IndexPath) {
    registerInterestModels[mainIndexPath.section].category.subCategories[subIndexPath.row].isSelected.toggle()
    let id = registerInterestModels[mainIndexPath.section].category.subCategories[subIndexPath.row].id
    cell.isTapped.toggle()
    cell.isTapped ? viewModel.selectSubCategory.onNext(id) : viewModel.deselectSubCategory.onNext(id)
  }
}

extension MeetingCategoryViewController: RegisterInterestTableViewCellDelegate {
  func didTappedIndicatorButton(cell: RegisterInterestTableViewCell) {
    guard let indexPath = tableView.indexPath(for: cell) else { return }
    registerInterestModels[indexPath.section].isExpanded.toggle()
    tableView.reloadSections([indexPath.section], with: .none)
  }
}
