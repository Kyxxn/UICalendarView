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
        return view.bounds.height / 2 // 초기 위치 (화면의 절반)
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
        panGesture.delegate = self
        view.addGestureRecognizer(panGesture)
    }

    // MARK: - Gesture Handling

    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view).y
        let velocity = gesture.velocity(in: view).y

        switch gesture.state {
        case .changed:
            // contentView의 상단 제약 조건을 업데이트
            var newTop = (contentViewTopConstraint?.layoutConstraints.first?.constant ?? contentViewTopCollapsed) + translation

            // newTop 값을 제한
            newTop = max(contentViewTopExpanded, min(contentViewTopCollapsed, newTop))

            contentViewTopConstraint?.update(offset: newTop)
            gesture.setTranslation(.zero, in: view)
            view.layoutIfNeeded()

        case .ended, .cancelled:
            // 제스처 종료 시 위치와 속도를 기반으로 애니메이션 처리
            let currentTop = contentViewTopConstraint?.layoutConstraints.first?.constant ?? contentViewTopCollapsed
            let shouldExpand: Bool

            if abs(velocity) > 500 {
                shouldExpand = velocity < 0 // 위로 스와이프하면 contentView를 확장
            } else {
                let middle = (contentViewTopCollapsed + contentViewTopExpanded) / 2
                shouldExpand = currentTop < middle
            }

            let targetTop = shouldExpand ? contentViewTopExpanded : contentViewTopCollapsed

            UIView.animate(withDuration: 0.3, animations: {
                self.contentViewTopConstraint?.update(offset: targetTop)
                self.view.layoutIfNeeded()
            })

        default:
            break
        }
    }
}

extension SplitCalendarViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == panGesture {
            // 테이블 뷰의 스크롤 위치가 최상단일 때만 제스처를 인식
            return scheduleTableView.contentOffset.y <= 0
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
