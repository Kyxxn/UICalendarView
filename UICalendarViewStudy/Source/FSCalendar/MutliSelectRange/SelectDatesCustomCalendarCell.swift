//
//  SelectDatesCustomCalendarCell.swift
//  UICalendarViewStudy
//
//  Created by 박효준 on 8/25/24.
//

import FSCalendar
import Foundation
import SnapKit
import Then

// UICollectionViewCell 상속받고 있음
class SelectDatesCustomCalendarCell: FSCalendarCell {
    
    var circleBackImageView = UIImageView()
    var leftRectBackImageView = UIImageView()
    var rightRectBackImageView = UIImageView()
    
    override init!(frame: CGRect) {
        super.init(frame: frame)
        
        setConfigure()
        setConstraints()
        settingImageView()
    }
    
    required init!(coder aDecoder: NSCoder!) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setConfigure() {
        
        contentView.insertSubview(circleBackImageView, at: 0)
        contentView.insertSubview(leftRectBackImageView, at: 0)
        contentView.insertSubview(rightRectBackImageView, at: 0)
    }
    
    func setConstraints() {
        
        // 날짜 텍스트의 레이아웃을 센터로 잡아준다 (기본적으로 약간 위에 있다)
        self.titleLabel.snp.makeConstraints { make in
            make.center.equalTo(contentView)
        }
        
        leftRectBackImageView.snp.makeConstraints { make in
            make.leading.equalTo(contentView)
            make.trailing.equalTo(contentView.snp.centerX)
            make.height.equalTo(46)
            make.centerY.equalTo(contentView)
        }
        
        circleBackImageView.snp.makeConstraints { make in
            make.center.equalTo(contentView)
            make.size.equalTo(46)
        }
        
        rightRectBackImageView.snp.makeConstraints { make in
            make.leading.equalTo(contentView.snp.centerX)
            make.trailing.equalTo(contentView)
            make.height.equalTo(46)
            make.centerY.equalTo(contentView)
        }
        
    }
    
    func settingImageView() {
        circleBackImageView.clipsToBounds = true
        circleBackImageView.layer.cornerRadius = 23
        
        // 선택 날짜의 배경 색상을 여기서 정한다.
        [circleBackImageView, leftRectBackImageView, rightRectBackImageView].forEach { item  in
            item.backgroundColor = .blue
        }
    }
}

extension SelectDatesCustomCalendarCell {
    func updateBackImage(_ dateType: SelectedDateType) {
        switch dateType {
        case .singleDate:
            // left right hidden true
            // circle hidden false
            leftRectBackImageView.isHidden = true
            rightRectBackImageView.isHidden = true
            circleBackImageView.isHidden = false
            circleBackImageView.backgroundColor = .blue // 기본 선택된 날짜 색상
            
        case .firstDate:
            // leftRect hidden true
            // circle, right hidden false
            leftRectBackImageView.isHidden = true
            circleBackImageView.isHidden = false
            rightRectBackImageView.isHidden = false
            circleBackImageView.backgroundColor = .black // 시작일의 원 색상

            
        case .middleDate:
            // circle hidden true
            // left, right hidden false
            circleBackImageView.isHidden = true
            leftRectBackImageView.isHidden = false
            rightRectBackImageView.isHidden = false
            
        case .lastDate:
            // rightRect hidden true
            // circle, left hidden false
            rightRectBackImageView.isHidden = true
            circleBackImageView.isHidden = false
            leftRectBackImageView.isHidden = false
            circleBackImageView.backgroundColor = .black // 시작일의 원 색상

            
        case .notSelected:
            // all hidden
            circleBackImageView.isHidden = true
            leftRectBackImageView.isHidden = true
            rightRectBackImageView.isHidden = true
        }
    }
}
