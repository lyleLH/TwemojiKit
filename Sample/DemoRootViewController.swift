//
//  DemoRootViewController.swift
//  AppTwemojiSample
//

import UIKit
import TwemojiKit

@available(iOS 15.0, *)
class DemoRootViewController: UIViewController, TwemojiPickerViewControllerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        let button = UIButton(type: .system)
        button.setTitle("Open TwemojiPicker", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.addTarget(self, action: #selector(openPicker), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Auto-present for testing
        openPicker()
    }

    @objc private func openPicker() {
        let picker = TwemojiPickerViewController()
        picker.delegate = self
        picker.isSingleSelection = true
        picker.modalPresentationStyle = .pageSheet
        if let sheet = picker.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
            sheet.prefersScrollingExpandsWhenScrolledToEdge = true
            sheet.preferredCornerRadius = 32
        }
        present(picker, animated: true)
    }

    func twemojiPicker(_ picker: TwemojiPickerViewController, didSelectEmojis emojis: [String]) {
        print("Selected: \(emojis)")
    }

    func twemojiPickerDidCancel(_ picker: TwemojiPickerViewController) {
        picker.dismiss(animated: true)
    }
}
