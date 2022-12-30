//
//  SelectedCategoryInfoView.swift
//  PLUB
//
//  Created by 이건준 on 2022/12/23.
//

import UIKit

struct SelectedCategoryInfoViewModel {
    let date: String
    let time: String
    let peopleCount: Int
}

enum SelectedCategoryInfoViewType {
    case Vertical
    case Horizontal
}

class SelectedCategoryInfoView: UIView {
    private let selectedCategoryInfoViewType: SelectedCategoryInfoViewType
    
    private lazy var categoryInfoStackView = UIStackView(arrangedSubviews: [dateStackView, timeStackView, peopleStackView]).then {
        $0.alignment = .leading
        $0.distribution = .fillEqually
    }
    
    private lazy var dateStackView = UIStackView(arrangedSubviews: [dateImageView, dateLabel])
    
    private lazy var timeStackView = UIStackView(arrangedSubviews: [timeImageView, timeLabel])
    
    private lazy var peopleStackView = UIStackView(arrangedSubviews: [peopleImageView, peopleLabel])
    
    private let dateImageView = UIImageView().then {
        $0.image = UIImage(named: "Calendar")
        $0.contentMode = .scaleAspectFit
    }
    
    private let dateLabel = UILabel().then {
        $0.textColor = .white
        $0.font = .systemFont(ofSize: 13, weight: .regular)
        $0.sizeToFit()
    }
    
    private let timeImageView = UIImageView().then {
        $0.image = UIImage(named: "Time")
        $0.contentMode = .scaleAspectFit
    }
    
    private let timeLabel = UILabel().then {
        $0.textColor = .white
        $0.font = .systemFont(ofSize: 13, weight: .regular)
        $0.sizeToFit()
    }
    
    private let peopleImageView = UIImageView().then {
        $0.image = UIImage(named: "People")
        $0.contentMode = .scaleAspectFit
    }
    
    private let peopleLabel = UILabel().then {
        $0.textColor = .white
        $0.font = .systemFont(ofSize: 13, weight: .regular)
        $0.sizeToFit()
    }
    
    init(selectedCategoryInfoViewType: SelectedCategoryInfoViewType) {
        self.selectedCategoryInfoViewType = selectedCategoryInfoViewType
        super.init(frame: .zero)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        _ = [dateStackView, timeStackView, peopleStackView].map{
            $0.spacing = 1
            $0.distribution = .fillProportionally
            $0.axis = .horizontal
        }
        
        addSubview(categoryInfoStackView)
        categoryInfoStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        switch selectedCategoryInfoViewType {
            case .Vertical:
                categoryInfoStackView.axis = .vertical
            case .Horizontal:
                categoryInfoStackView.axis = .horizontal
        }
    }
    
    public func configureUI(with model: SelectedCategoryInfoViewModel) {
        dateLabel.text = model.date
        timeLabel.text = model.time
        peopleLabel.text = "참여인원 \(String(model.peopleCount))명"
    }
}
