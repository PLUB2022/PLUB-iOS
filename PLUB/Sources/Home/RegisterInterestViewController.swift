//
//  RegisterInterestViewController.swift
//  PLUB
//
//  Created by 이건준 on 2022/10/07.
//

import UIKit
import SnapKit
import Then

class RegisterInterestViewController: BaseViewController {
    
    private let viewModel: RegisterInterestViewModelType
    
    private var registerInterestModels: [RegisterInterestModel] = []
//    private var rgisterInterestModels: [RegisterInterestViewControllerModel] = [
//        .init(interestCollectionType: .Art),
//        .init(interestCollectionType: .SportFitness),
//        .init(interestCollectionType: .Investment),
//        .init(interestCollectionType: .LanguageStudy),
//        .init(interestCollectionType: .Culture),
//        .init(interestCollectionType: .Food),
//        .init(interestCollectionType: .Employment),
//        .init(interestCollectionType: .Computer),
//    ]
    
    private let registerTableView = UITableView(frame: .zero, style: .grouped).then {
        $0.backgroundColor = .systemBackground
        $0.sectionFooterHeight = .leastNonzeroMagnitude
    }
    
    init(viewModel: RegisterInterestViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .secondarySystemBackground
        setTableView(registerTableView)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.backward", withConfiguration: UIImage.SymbolConfiguration(hierarchicalColor: .black)),
            style: .done,
            target: self,
            action: #selector(didTappedLeftButton)
        )
        
//        setTableHeaderView(registerTableView)
    }
    
    override func setupLayouts() {
        view.addSubview(registerTableView)
    }
    
    override func setupConstraints() {
        registerTableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    override func setupStyles() {
        
    }
    
    override func bind() {
        viewModel.createInterestSection()
            .subscribe(onNext: { registerInterestModels in
                self.registerInterestModels = registerInterestModels
            })
            .disposed(by: disposeBag)
    }
    
    @objc private func didTappedLeftButton() {
        self.navigationController?.popViewController(animated: true)
    }
    
    private func setTableView(_ tableView: UITableView) {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(RegisterInterestTableViewCell.self, forCellReuseIdentifier: RegisterInterestTableViewCell.identifier)
        tableView.register(RegisterInterestHeaderView.self, forHeaderFooterViewReuseIdentifier: RegisterInterestHeaderView.identifier)
        tableView.register(RegisterInterestDetailTableViewCell.self, forCellReuseIdentifier: RegisterInterestDetailTableViewCell.identifier)
    }
}

extension RegisterInterestViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return InterestCollectionType.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if registerInterestModels[section].isExpanded {
            return 2
        }
        return 1 // rgisterInterestModels[section].interestCollectionTypes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: RegisterInterestDetailTableViewCell.identifier, for: indexPath) as? RegisterInterestDetailTableViewCell ?? RegisterInterestDetailTableViewCell()
            let registerInterestDetailTableViewCellModel = RegisterInterstDetailTableViewCellModel( // 화면을 표시하기위한 Mock
                interestDetailTypes: [
                    .Art, .Computer, .Culture, .Employment, .Food, .Investment, .SportFitness, .LanguageStudy, .Employment, .SportFitness
                ]
            )
            cell.configureUI(with: registerInterestDetailTableViewCellModel)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: RegisterInterestTableViewCell.identifier, for: indexPath) as? RegisterInterestTableViewCell ?? RegisterInterestTableViewCell()
            let registerInterstVCModel = registerInterestModels[indexPath.section]
            let registerInterestTableViewCellModel = RegisterInterestTableViewCellModel(
                imageName: registerInterstVCModel.interestCollectionType.imageNamed,
                title: registerInterstVCModel.interestCollectionType.title,
                description: "PLUB! 에게 관심사를 선택해주세요",
                isExpanded: registerInterstVCModel.isExpanded
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
