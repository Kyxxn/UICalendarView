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

class FSCalendarViewController: UIViewController {

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
        
        // 멀티 선택 가능하도록 설정
        $0.allowsMultipleSelection = true
    }
    
    let headerLabel = UILabel().then {
        $0.font = UIFont.boldSystemFont(ofSize: 18)
        $0.textColor = .systemGray
        $0.textAlignment = .left
    }
    
    let headerDateFormatter = DateFormatter().then {
        $0.dateFormat = "yyyy년 M월"
    }
    
    let dateFormatter = DateFormatter().then {
        $0.dateFormat = "yyyy-MM-dd" // 날짜 비교
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        setCalendar()
        selectPresetDates() // 미리 선택된 날짜 설정
    }
    
    func setCalendar() {
        calendarView.delegate = self
        calendarView.dataSource = self
        calendarView.headerHeight = 0  // 기본 헤더 숨기기
        calendarView.scope = .month
        headerLabel.text = self.headerDateFormatter.string(from: calendarView.currentPage)
    }
    
    func selectPresetDates() {
        let presetDates = ["2024-08-02", "2024-08-05", "2024-08-07"]
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        for dateString in presetDates {
            if let date = dateFormatter.date(from: dateString) {
                calendarView.select(date)
            }
        }
    }
}

// MARK: - FSCalendarDelegate
/// 클릭됐을 때 동작
extension FSCalendarViewController: FSCalendarDelegate {
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        self.headerLabel.text = self.headerDateFormatter.string(from: calendar.currentPage)
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let dateString = dateFormatter.string(from: date)
        print("선택된 날짜: \(dateString)")
    }
}

// MARK: - FSCalendarDataSource
/// 점들의 개수 지정
extension FSCalendarViewController: FSCalendarDataSource {
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        let dateString = dateFormatter.string(from: date)
        
        if dateString == "2024-08-20" || dateString == "2024-08-22" {
            return 3
        }
        
        if dateString == "2024-08-17" {
            return 2
        }
        
        return 0
    }
}

// MARK: - FSCalendarDelegateAppearance
/// 점들의 색상 조정 (데코레이션)
extension FSCalendarViewController: FSCalendarDelegateAppearance {
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventDefaultColorsFor date: Date) -> [UIColor]? {
        let dateString = dateFormatter.string(from: date)
        print("Event Color Check for Date: \(dateString)") // 로그 출력
        
        if dateString == "2024-08-20" || dateString == "2024-08-22" {
            print("Setting colors for 2024-08-20 or 2024-08-22")
            return [.red, .blue, .systemPink]
        }
        
        if dateString == "2024-08-17" {
            print("Setting colors for 2024-08-17")
            return [.green, .purple]
        }
        
        return nil
    }
}

extension FSCalendarViewController {
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
}
