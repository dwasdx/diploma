import UIKit

protocol SwipeableViewController: UIViewController {
    var initialFingerYPosition: CGFloat { get set }
    var currentFingerYPosition: CGFloat { get set }
    var currentFingerOffset: CGFloat { get }
    var defaultContainerViewHeight: CGFloat { get }
    var threshold: CGFloat { get }
    
    var scrollView: UIScrollView! { get set }
    var containerView: UIView! { get set }
    var scrollViewHeightAnchor: NSLayoutConstraint! { get set }
    
    var didDismiss: (() -> Void)? { get }
    
    func dismiss(_ completion: @escaping (() -> Void))
    func didSwipeContainerView(_ sender: UIPanGestureRecognizer)
}

extension SwipeableViewController {
    var currentFingerOffset: CGFloat {
        currentFingerYPosition - initialFingerYPosition
    }
    
    func didSwipeContainerView(_ sender: UIPanGestureRecognizer) {
        guard sender.view == containerView else {
            return
        }
        let translation = sender.translation(in: sender.view?.superview?.superview)
        
        switch sender.state {
            case .began:
                self.initialFingerYPosition = translation.y
            case .changed:
                self.currentFingerYPosition = translation.y
                if currentFingerOffset < 0 {
                    return
                }
                self.scrollViewHeightAnchor.constant = self.defaultContainerViewHeight - self.currentFingerOffset
                UIView.animate(withDuration: 0.05,
                               delay: 0,
                               options: .curveEaseInOut,
                               animations: {
                                self.view.layoutIfNeeded()
                },
                               completion: nil)
            case .ended:
                if self.currentFingerOffset > self.defaultContainerViewHeight * threshold {
                    dismiss {
                        self.didDismiss?()
                    }
                } else {
                    self.scrollViewHeightAnchor.constant = self.defaultContainerViewHeight
                    UIView.animate(withDuration: 0.2,
                                   delay: 0,
                                   options: .curveEaseInOut, animations: {
                                    self.view.layoutIfNeeded()
                    },
                                   completion: nil)
            }
            default:
                break
        }
    }
}

//extension SwipeableViewController {
//    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizerDelegate) -> Bool {
//        guard let gesture = gestureRecognizer as? UIPanGestureRecognizer else {
//            return false
//        }
//        let direction = gesture.velocity(in: gesture.view).y
//
//        if scrollView.contentOffset.y == 0, direction > 0 {
//            print("will return false")
//            return false
//        }
//        print("will return true")
//        return true
//    }
//}
