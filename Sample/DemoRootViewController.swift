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
        if !hasPresented {
            hasPresented = true
            openPicker()
        }
    }

    private var hasPresented = false

    @objc private func openPicker() {
        let picker = TwemojiPickerViewController()
        picker.delegate = self
        picker.isSingleSelection = false
        let nav = UINavigationController(rootViewController: picker)
        nav.modalPresentationStyle = .pageSheet
        if let sheet = nav.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
            sheet.prefersScrollingExpandsWhenScrolledToEdge = true
            sheet.preferredCornerRadius = 32
        }
        present(nav, animated: true)
    }

    func twemojiPicker(_ picker: TwemojiPickerViewController, didSelectEmojis emojis: [String]) {
        print("Selected: \(emojis)")
    }

    func twemojiPickerDidCancel(_ picker: TwemojiPickerViewController) {
        picker.dismiss(animated: true)
    }
}
