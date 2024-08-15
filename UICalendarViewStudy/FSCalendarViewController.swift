//
//  FSCalendarViewController.swift
//  UICalendarViewStudy
//
//  Created by 박효준 on 8/15/24.
//
import UIKit
import FSCalendar
import SnapKit
import Then

class FSCalendarViewController: UIViewController, FSCalendarDelegate, FSCalendarDataSource {

    let calendarView = FSCalendar().then {
        $0.scrollDirection = .horizontal
        $0.locale = Locale(identifier: "ko_KR")
        $0.backgroundColor = .systemBackground
        $0.scope = .month
        
        // 요일 텍스트 색상 지정
        $0.appearance.weekdayTextColor = .gray
        
        // 인접한 달의 날짜 숨기기
        $0.placeholderType = .none

        // 인접한 달의 헤더 텍스트 숨기기
        $0.appearance.headerMinimumDissolvedAlpha = 0.0
    }
    
    let headerLabel = UILabel().then {
        $0.font = UIFont.boldSystemFont(ofSize: 18)
        $0.textColor = .systemGray
        $0.textAlignment = .left
    }
    
    let dateFormatter = DateFormatter().then {
        $0.dateFormat = "yyyy년 MM월"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        setCalendar()
    }
    
    func setupUI() {
        view.addSubview(headerLabel)
        view.addSubview(calendarView)
        
        headerLabel.snp.makeConstraints {
            $0.leading.equalTo(view).offset(10)
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
        }
        
        calendarView.snp.makeConstraints {
            $0.leading.equalTo(view).offset(10)
            $0.trailing.equalTo(view).offset(-10)
            $0.top.equalTo(headerLabel.snp.bottom).offset(100)
            $0.height.equalTo(300)
        }
    }
    
    func setCalendar() {
        calendarView.delegate = self
        calendarView.headerHeight = 0  // 기본 헤더 숨기기
        calendarView.scope = .month
        headerLabel.text = self.dateFormatter.string(from: calendarView.currentPage)
    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        self.headerLabel.text = self.dateFormatter.string(from: calendar.currentPage)
    }
    
    // MARK: - FSCalendarDataSource
    // 이거 아직 안됨
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        let dateString = dateFormatter.string(from: date)
        
        if dateString == "2024-08-20" || dateString == "2024-08-22" {
            return 3
        }
        
        return 0
    }
    
    // MARK: - FSCalendarDelegateAppearance
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventDefaultColorsFor date: Date) -> [UIColor]? {
        let dateString = dateFormatter.string(from: date)
        
        if dateString == "2024-08-20" || dateString == "2024-08-22" {
            return [.red, .blue, .yellow]
        }
        
        return nil
    }
    
    // MARK: - FSCalendarDelegate
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let dateString = dateFormatter.string(from: date)
        print("선택된 날짜: \(dateString)")
    }
}
