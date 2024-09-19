//
//  SplitCalendarViewController.swift
//  UICalendarViewStudy
//
//  Created by 박효준 on 9/19/24.
//

import UIKit
import FSCalendar
import SnapKit
import Then

final class SplitCalendarViewController: UIViewController {
    
    
    // MARK: - UIComponenets
    
    let calendar = FSCalendar().then {
        $0.today = nil
        $0.backgroundColor = .white
        $0.appearance.selectionColor = .red
    }
    
    let contentView = UIView().then {
        $0.backgroundColor = .white
    }
    
    let separatorView = UIView().then {
        $0.backgroundColor = .darkGray
    }
    
    let grabBar = UIView().then {
        $0.backgroundColor = .darkGray
    }
    
    let scheduleTableView = UITableView().then {
        $0.backgroundColor = .red
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .blue
        
        setupGesture()
        setupConfiguration()
        setupLayout()
    }
    
    private func setupGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureAction))
        view.addGestureRecognizer(panGesture)
    }
    
    @objc func panGestureAction() {
        // 스크롤함에 따라 calendarView와 ContentView 길이가 조절되어야 함
        
    }
    
    private func setupConfiguration() {
        scheduleTableView.delegate = self
        scheduleTableView.dataSource = self
        
        view.addSubview(calendar)
        view.addSubview(contentView)
        contentView.addSubview(separatorView)
        contentView.addSubview(grabBar)
        contentView.addSubview(scheduleTableView)
    }
    
    private func setupLayout() {
        calendar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.5)
        }
        
        contentView.snp.makeConstraints { make in
            make.top.equalTo(calendar.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        separatorView.snp.makeConstraints {
            $0.top.equalTo(contentView.snp.top)
            $0.width.equalToSuperview()
            $0.height.equalTo(1)
        }
        
        grabBar.snp.makeConstraints { make in
            make.top.equalTo(separatorView.snp.bottom).offset(5)
            make.centerX.equalToSuperview()
            make.width.equalTo(35)
            make.height.equalTo(5)
        }
        
        scheduleTableView.snp.makeConstraints { make in
            make.top.equalTo(grabBar.snp.bottom).offset(3)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
}

extension SplitCalendarViewController: UITableViewDelegate {
    
}

extension SplitCalendarViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
        cell.contentView.backgroundColor = .purple
        cell.textLabel?.text = "테이블뷰 셀: \(indexPath.row + 1)"
        cell.textLabel?.textColor = .white
        return cell
    }
}
