import UIKit

public final class Toast {
    public static func setup(keyWindow: UIWindow) {
        Self.keyWindow = keyWindow
    }
    
    static var keyWindow: UIWindow?
}
