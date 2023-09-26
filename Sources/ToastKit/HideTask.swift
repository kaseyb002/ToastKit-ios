import UIKit

struct HideTask: Equatable {
    let superview: WeakBox<UIView>
    let toastView: WeakBox<ToastView>
    let task: Task<Void, Error>
    
    init(
        superview: UIView,
        toastView: ToastView,
        task: Task<Void, Error>
    ) {
        self.superview = .init(superview)
        self.toastView = .init(toastView)
        self.task = task
    }
    
    static func ==(lhs: Self, rhs: Self) -> Bool {
        lhs.superview.underlying == rhs.superview.underlying
    }
}

var hideTasks: [HideTask] = []

func existingTask(for superview: UIView) -> HideTask? {
    hideTasks.first(where: { $0.superview.underlying == superview })
}
