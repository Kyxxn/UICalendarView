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
    
    let nabbar = UILabel().then {
        $0.text = "네브바"
        $0.textAlignment = .center
        $0.backgroundColor = .black
    }

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

        view.addSubview(nabbar)
        view.addSubview(calendar)
        view.addSubview(contentView)
        contentView.addSubview(separatorView)
        contentView.addSubview(grabBar)
        contentView.addSubview(scheduleTableView)
    }

    private func setupLayout() {
        nabbar.snp.makeConstraints {
            $0.top.equalTo(view.snp.top).offset(15)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(30)
        }
        
        calendar.snp.makeConstraints { make in
            make.top.equalTo(nabbar.snp.bottom) // nabbar 아래에 위치
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(contentView.snp.top) // calendar의 하단을 contentView의 상단에 연결
        }

        contentView.snp.makeConstraints { make in
            // 초기 위치를 절반으로 설정하지만, 팬 제스처로 상단까지 이동 가능
            self.contentViewTopConstraint = make.top.equalToSuperview().inset(view.bounds.height / 2).constraint
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

        // 1. 상태별로 위치 설정
        let contentViewTopExpanded = nabbar.frame.height + 15 // nabbar 바로 아래
        let contentViewTopCollapsed = view.bounds.height / 2 // 화면의 절반
        let contentViewTopHidden = view.bounds.height // 화면 밖으로 사라지는 상태

        switch gesture.state {
        case .changed:
            // 2. 변경된 위치 계산: 화면 상단에서 하단까지 범위 설정
            var newTop = (contentViewTopConstraint?.layoutConstraints.first?.constant ?? contentViewTopCollapsed) + translation
            // newTop 값을 상단 (contentViewTopExpanded)과 하단 (contentViewTopHidden) 사이로 제한
            newTop = max(contentViewTopExpanded, min(contentViewTopHidden, newTop))
            contentViewTopConstraint?.update(offset: newTop)
            gesture.setTranslation(.zero, in: view)
            view.layoutIfNeeded()

            // 캘린더 크기 업데이트
            calendar.reloadData()
            calendar.setNeedsLayout()
            calendar.layoutIfNeeded()

        case .ended, .cancelled:
            let currentTop = contentViewTopConstraint?.layoutConstraints.first?.constant ?? contentViewTopCollapsed
            let shouldExpand: Bool
            let shouldCollapse: Bool
            let shouldHide: Bool

            // 속도에 따른 상태 결정
            if abs(velocity) > 500 {
                shouldExpand = velocity < 0 // 위로 빠르게 스와이프하면 확장
                shouldHide = velocity > 0 && currentTop > contentViewTopCollapsed + 100 // 아래로 빠르게 스와이프하면 숨김
            } else {
                let middlePosition = (contentViewTopCollapsed + contentViewTopExpanded) / 2
                shouldExpand = currentTop < middlePosition // 중간보다 위에 있으면 확장
                shouldHide = currentTop >= contentViewTopHidden - 100 // 하단 근처에 있으면 숨김
            }

            // 상태에 따른 목표 위치 설정
            let targetTop: CGFloat
            if shouldExpand {
                targetTop = contentViewTopExpanded // 네브바 바로 아래까지 확장
            } else if shouldHide {
                targetTop = contentViewTopHidden // 화면 아래로 숨김
            } else {
                targetTop = contentViewTopCollapsed // 반반 위치
            }

            // 애니메이션 적용
            UIView.animate(withDuration: 0.3, animations: {
                self.contentViewTopConstraint?.update(offset: targetTop)
                self.view.layoutIfNeeded()
                // 애니메이션 중 캘린더 업데이트
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
