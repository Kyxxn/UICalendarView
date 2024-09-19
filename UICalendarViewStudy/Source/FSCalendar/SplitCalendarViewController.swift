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

    // MARK: - Properties

    private var contentViewTopConstraint: Constraint?
    private let contentViewTopExpanded: CGFloat = 0 // contentView가 화면을 가득 채울 때
    private var contentViewTopCollapsed: CGFloat {
        return view.bounds.height / 2 // 화면의 절반
    }
    private var contentViewTopHidden: CGFloat {
        return view.bounds.height // 화면 밖으로 나가는 상태
    }
    private var panGesture: UIPanGestureRecognizer!

    // MARK: - UI Components

    let calendar = FSCalendar().then {
        $0.today = nil
        $0.backgroundColor = .green
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

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .blue

        setupConfiguration()
        setupLayout()
        setupGesture()
    }

    // MARK: - Setup Methods

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
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(contentView.snp.top) // calendar의 하단을 contentView의 상단에 연결
        }

        contentView.snp.makeConstraints { make in
            self.contentViewTopConstraint = make.top.equalTo(view.snp.centerY).constraint // 초기 위치를 화면의 절반으로 설정
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

    private func setupGesture() {
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        
        view.addGestureRecognizer(panGesture)
    }

    // MARK: - Gesture Handling

//    화면을 꽉 채우는 상태, 반반으로 나뉘는 중간 상태, 그리고 화면에서 사라지는 상태로 contentView를 관리해야 됨
//    + contentView가 내려가면 캘린더의 날짜 셀의 높이도 맞춰서 길어져야 함
//
//        1.    화면을 꽉 채우는 상태
//        2.    화면의 절반을 차지하는 중간 상태
//        3.    화면에서 사라지는 상태
//    handlePanGesture의 로직이 잘못된 거 같음
//    화면을 다 덮는 게 안되고 있음
    
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view).y
        let velocity = gesture.velocity(in: view).y

        switch gesture.state {
        case .changed:
            var newTop = (contentViewTopConstraint?.layoutConstraints.first?.constant ?? contentViewTopCollapsed) + translation
            newTop = min(contentViewTopCollapsed, newTop)
            contentViewTopConstraint?.update(offset: newTop)
            gesture.setTranslation(.zero, in: view)
            view.layoutIfNeeded()

            // Reload the calendar to update cell sizes
            calendar.reloadData()
            calendar.setNeedsLayout()
            calendar.layoutIfNeeded()
        case .ended, .cancelled:
            let currentTop = contentViewTopConstraint?.layoutConstraints.first?.constant ?? contentViewTopCollapsed
            let shouldExpand: Bool

            if abs(velocity) > 500 {
                shouldExpand = velocity < 0
            } else {
                let middle = (contentViewTopCollapsed + contentViewTopExpanded) / 2
                shouldExpand = currentTop < middle
            }

            let targetTop = shouldExpand ? contentViewTopExpanded : contentViewTopCollapsed

            UIView.animate(withDuration: 0.3, animations: {
                self.contentViewTopConstraint?.update(offset: targetTop)
                self.view.layoutIfNeeded()
                // Reload the calendar during animation
                self.calendar.reloadData()
            })

        default:
            break
        }
    }
}

extension SplitCalendarViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == panGesture {
            let location = gestureRecognizer.location(in: contentView)
            // scheduleTableView 영역에서 제스처를 인식하지 않도록 함
            if scheduleTableView.frame.contains(location) && scheduleTableView.contentOffset.y > 0 {
                return false
            }
        }
        return true
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}

extension SplitCalendarViewController: UITableViewDelegate {

}

extension SplitCalendarViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        20 // 데이터를 늘려 스크롤이 가능하도록 함
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
        cell.contentView.backgroundColor = .purple
        cell.textLabel?.text = "테이블뷰 셀: \(indexPath.row + 1)"
        cell.textLabel?.textColor = .white
        return cell
    }
}
