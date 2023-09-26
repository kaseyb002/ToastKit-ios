import UIKit

public func showToast(
    _ title: String,
    icon: UIImage? = nil,
    duration: TimeInterval = 1.5
) {
    Task { @MainActor in
        guard let topView: UIView = topViewController(controller: Toast.keyWindow?.rootViewController)?.view else {
            return
        }

        removeToastViewIfNeeded(from: topView)

        let toastView: ToastView = makeToastView(
            title: title,
            icon: icon,
            topView: topView
        )

        present(
            toastView: toastView,
            on: topView
        )

        hide(
            toast: toastView,
            in: topView,
            afterDelay: duration
        )
    }
}

private func removeToastViewIfNeeded(from topView: UIView) {
    if let toastView: ToastView = existingTask(for: topView)?.toastView.underlying ?? topView.subviews.findRecursively(ToastView.self) {
        immediatelyRemove(toastView)
    }
    removeHideTask(for: topView)
}

private func present(
    toastView: ToastView,
    on topView: UIView
) {
    let (showingConstraint, hidingConstraint): (NSLayoutConstraint, NSLayoutConstraint) = makeShowingAndHidingContraints(
        toastView: toastView,
        topView: topView
    )

    topView.layoutIfNeeded()
    UIView.animate(withDuration: 0.3) { [weak topView] in
        hidingConstraint.isActive = false
        showingConstraint.isActive = true
        topView?.layoutIfNeeded()
    }
}

func hide(
    toast: ToastView,
    in superview: UIView,
    afterDelay duration: TimeInterval
) {
    let task: Task<Void, Error> = Task {
        try await Task.sleep(for: .seconds(duration))
        await MainActor.run {
            guard let existingTask: HideTask = existingTask(for: superview),
                    existingTask.task.isCancelled == false
            else {
                immediatelyRemove(toast)
                removeHideTask(for: superview)
                return
            }
            hide(toastView: toast, in: superview)
        }
    }
    hideTasks.append(.init(
        superview: superview,
        toastView: toast,
        task: task
    ))
}

private func removeHideTask(for superview: UIView) {
    guard let hideTask: HideTask = existingTask(for: superview) else {
        return
    }
    hideTask.task.cancel()
    hideTasks.removeAll(where: { $0 == hideTask })
}

private func makeShowingAndHidingContraints(
    toastView: ToastView,
    topView: UIView
) -> (NSLayoutConstraint, NSLayoutConstraint) {
    let showingConstraint: NSLayoutConstraint = topView.safeAreaLayoutGuide.bottomAnchor.constraint(
        equalTo: toastView.bottomAnchor,
        constant: 20
    )
    showingConstraint.identifier = Constants.showingConstraintId
    let hidingConstraint: NSLayoutConstraint = toastView.topAnchor.constraint(
        equalTo: topView.bottomAnchor
    )
    hidingConstraint.identifier = Constants.hidingConstraintId
    hidingConstraint.isActive = true
    return (showingConstraint, hidingConstraint)
}

private func makeToastView(
    title: String,
    icon: UIImage?,
    topView: UIView
) -> ToastView {
    let toastView: ToastView = .init()
    toastView.label.text = title
    if let icon: UIImage = icon {
        toastView.iconView.isHidden = false
        toastView.iconView.image = icon.withRenderingMode(.alwaysTemplate)
    } else {
        toastView.iconView.isHidden = true
    }
    toastView.translatesAutoresizingMaskIntoConstraints = false
    topView.addSubview(toastView)
    toastView.centerXAnchor.constraint(
        equalTo: topView.centerXAnchor
    ).isActive = true
    toastView.widthAnchor.constraint(
        lessThanOrEqualTo: topView.widthAnchor,
        multiplier: 1
    ).isActive = true
    return toastView
}

func hide(
    toastView: ToastView,
    in superview: UIView
) {
    guard let showingConstraint: NSLayoutConstraint = superview.constraints.first(where: { $0.identifier == Constants.showingConstraintId }) else {
        removeHideTask(for: superview)
        return
    }
    
    let hidingConstraint: NSLayoutConstraint = toastView.topAnchor.constraint(equalTo: superview.bottomAnchor)
    hidingConstraint.identifier = Constants.hidingConstraintId
    
    superview.layoutIfNeeded()
    UIView.animate(
        withDuration: 0.4,
        delay: 0,
        animations: {
            showingConstraint.isActive = false
            hidingConstraint.isActive = true
            superview.layoutIfNeeded()
        },
        completion: { isCompleted in
            guard isCompleted else {
                return
            }
            immediatelyRemove(toastView)
            removeHideTask(for: superview)
        }
    )
}

private func immediatelyRemove(_ toastView: ToastView) {
    if let superview: UIView = toastView.superview {
        removeHideTask(for: superview)
    }
    toastView.removeFromSuperview()
}
