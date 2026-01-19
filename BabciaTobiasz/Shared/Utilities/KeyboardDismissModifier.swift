//
//  KeyboardDismissModifier.swift
//  BabciaTobiasz
//
//  Dismisses the keyboard when tapping outside text inputs.
//

import SwiftUI

#if os(iOS)
import UIKit
#endif

struct KeyboardDismissOnTapModifier: ViewModifier {
    func body(content: Content) -> some View {
#if os(iOS)
        content.background(KeyboardDismissTapView())
#else
        content
#endif
    }
}

#if os(iOS)
private struct KeyboardDismissTapView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        let recognizer = UITapGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handleTap(_:))
        )
        recognizer.cancelsTouchesInView = false
        recognizer.delegate = context.coordinator
        view.addGestureRecognizer(recognizer)
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    final class Coordinator: NSObject, UIGestureRecognizerDelegate {
        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            UIApplication.shared.sendAction(
                #selector(UIResponder.resignFirstResponder),
                to: nil,
                from: nil,
                for: nil
            )
        }

        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
            var view = touch.view
            while let current = view {
                if current is UITextField || current is UITextView {
                    return false
                }
                view = current.superview
            }
            return true
        }
    }
}
#endif

extension View {
    func dismissKeyboardOnTap() -> some View {
        modifier(KeyboardDismissOnTapModifier())
    }
}
