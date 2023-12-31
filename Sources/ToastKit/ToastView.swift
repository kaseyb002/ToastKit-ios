import UIKit

final class ToastView: UIView {
    // MARK: - Views
    private let stackView: UIStackView = makeStackView()
    let iconView: UIImageView = makeIconView()
    let label: UILabel = makeLabel()

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup
extension ToastView {
    private func setup() {
        backgroundColor = .label.withAlphaComponent(0.95)
        layer.cornerRadius = 10
        clipsToBounds = true
        addSubview(stackView)
        let verticalPadding: CGFloat = 12
        let horizontalPadding: CGFloat = 20
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: verticalPadding),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: horizontalPadding),
            bottomAnchor.constraint(equalTo: stackView.bottomAnchor, constant: verticalPadding),
            trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: horizontalPadding),
        ])
        stackView.addArrangedSubview(iconView)
        stackView.addArrangedSubview(label)
        let swipeToDismiss: UISwipeGestureRecognizer = makeSwipeToDismissGesture()
        addGestureRecognizer(swipeToDismiss)
    }

    private static func makeStackView() -> UIStackView {
        let stackView: UIStackView = .init()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.alignment = .center
        return stackView
    }

    private static func makeIconView() -> UIImageView {
        let imageView: UIImageView = .init()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.heightAnchor.constraint(equalToConstant: 25).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 25).isActive = true
        imageView.contentMode = .scaleAspectFill
        imageView.tintColor = .systemBackground
        return imageView
    }

    private static func makeLabel() -> UILabel {
        let label: UILabel = .init()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .systemBackground
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.numberOfLines = 0
        return label
    }
    
    private func makeSwipeToDismissGesture() -> UISwipeGestureRecognizer {
        let swipe: UISwipeGestureRecognizer = .init(
            target: self,
            action: #selector(didSwipeDown)
        )
        swipe.direction = .down
        return swipe
    }
    
    @objc
    private func didSwipeDown() {
        guard let superview: UIView = superview else{
            return
        }
        hide(toastView: self, in: superview)
    }
}

enum Constants {
    static let showingConstraintId: String = "showingToastConstraint"
    static let hidingConstraintId: String = "hidingToastConstraint"
}
