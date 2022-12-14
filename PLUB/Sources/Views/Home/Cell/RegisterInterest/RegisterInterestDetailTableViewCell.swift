//
//  RegisterInterestDetailTableViewCell.swift
//  PLUB
//
//  Created by 이건준 on 2022/12/18.
//

import UIKit

import SnapKit
import Then

protocol RegisterInterestDetailTableViewCellDelegate: AnyObject {
    func didTappedInterestTypeCollectionViewCell(cell: InterestTypeCollectionViewCell)
}

struct RegisterInterstDetailTableViewCellModel {
    let interestDetailTypes: [InterestCollectionType]
}

class RegisterInterestDetailTableViewCell: UITableViewCell {
    
    static let identifier = "RegisterInterestDetailTableViewCell"
    
    public weak var delegate: RegisterInterestDetailTableViewCellDelegate?
    
    private var registerInterstDetailTableViewCellModel: [InterestCollectionType] = []
    
    private let containerView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.white.cgColor
        $0.layer.masksToBounds = true
//        $0.layer.cornerRadius = 20
    }
    
    private let interestTypeCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout().then({
        $0.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    })).then {
        $0.backgroundColor = .systemBackground
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
        setCollectionView(interestTypeCollectionView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 20)
    }
    
    private func configureUI() {
        contentView.backgroundColor = .secondarySystemBackground
//        contentView.addShadow(cornerRadius: 8)
        contentView.addSubview(containerView)
        containerView.snp.makeConstraints { make in
//            make.edges.equalToSuperview()
            make.left.top.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-5)
        }
        
        containerView.addSubview(interestTypeCollectionView)
        interestTypeCollectionView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(202)
        }
    }
    
    public func configureUI(with model: RegisterInterestModel) {
        self.registerInterstDetailTableViewCellModel = model.interestDetailTypes
    }
    
    private func setCollectionView(_ collectionView: UICollectionView) {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(InterestTypeCollectionViewCell.self, forCellWithReuseIdentifier: InterestTypeCollectionViewCell.identifier)
    }
}

extension RegisterInterestDetailTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return registerInterstDetailTableViewCellModel.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: InterestTypeCollectionViewCell.identifier, for: indexPath) as? InterestTypeCollectionViewCell ?? InterestTypeCollectionViewCell()
        cell.configureUI(with: registerInterstDetailTableViewCellModel[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == self.interestTypeCollectionView {
            return CGSize(width: (collectionView.frame.width / 4) - 8 - 16, height: (collectionView.frame.height / 3) - 8 - 16)
        }
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? InterestTypeCollectionViewCell else {
            return
        }
        delegate?.didTappedInterestTypeCollectionViewCell(cell: cell)
//        cell.isTapped.toggle()
    }
}

