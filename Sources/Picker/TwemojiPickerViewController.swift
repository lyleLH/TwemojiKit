//
//  TwemojiPickerViewController.swift
//  TwemojiKit
//
//  Created by Claude on 2026-03-14.
//

import UIKit
import SwiftUI

// MARK: - Delegate Protocol

public protocol TwemojiPickerViewControllerDelegate: AnyObject {
    func twemojiPicker(_ picker: TwemojiPickerViewController, didSelectEmojis emojis: [String])
    func twemojiPickerDidCancel(_ picker: TwemojiPickerViewController)
}

// MARK: - TwemojiPickerViewController

/// UIKit wrapper around TwemojiPickerView.
///
/// Usage:
/// ```swift
/// let picker = TwemojiPickerViewController()
/// picker.delegate = self
/// picker.isSingleSelection = true
/// picker.modalPresentationStyle = .pageSheet
/// if let sheet = picker.sheetPresentationController {
///     sheet.detents = [.medium(), .large()]
///     sheet.prefersGrabberVisible = true
/// }
/// present(picker, animated: true)
/// ```
@available(iOS 15.0, *)
public class TwemojiPickerViewController: UIViewController {

    public weak var delegate: TwemojiPickerViewControllerDelegate?

    /// Arbitrary context for identifying which UI element triggered the picker.
    public var presentingIndexPath: IndexPath?

    /// When true, selecting an emoji immediately calls the delegate and dismisses.
    public var isSingleSelection: Bool = false

    /// Custom sections. If nil, uses the built-in default categories.
    public var sections: [TwemojiPickerSection]?

    /// Recent emojis to show. Pass from your persistence layer.
    public var recentEmojis: [String] = []

    private static let defaultRecentStore = TwemojiRecentStore()

    override public func viewDidLoad() {
        super.viewDidLoad()

        let currentSections = sections ?? Self.defaultSections
        let recents = recentEmojis.isEmpty ? Self.defaultRecentStore.emojis : recentEmojis

        let pickerView = NavigationView {
            TwemojiPickerView(
                sections: currentSections,
                recentEmojis: recents,
                columns: 6,
                onSelect: { [weak self] emoji in
                    guard let self = self else { return }
                    Self.defaultRecentStore.record(emoji)
                    self.delegate?.twemojiPicker(self, didSelectEmojis: [emoji])
                    if self.isSingleSelection {
                        self.dismiss(animated: true)
                    }
                }
            )
            .navigationTitle(TwemojiL10n("twemoji.picker.title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(TwemojiL10n("twemoji.picker.cancel")) { [weak self] in
                        guard let self = self else { return }
                        self.delegate?.twemojiPickerDidCancel(self)
                        self.dismiss(animated: true)
                    }
                }
            }
        }

        let hostingController = UIHostingController(rootView: pickerView)
        addChild(hostingController)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hostingController.view)
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        hostingController.didMove(toParent: self)
    }

    // MARK: - Default Sections

    private static let defaultSections: [TwemojiPickerSection] = [
        TwemojiPickerSection(title: TwemojiL10n("twemoji.category.smileys"), emojis: smileys),
        TwemojiPickerSection(title: TwemojiL10n("twemoji.category.hearts"), emojis: hearts),
        TwemojiPickerSection(title: TwemojiL10n("twemoji.category.people"), emojis: hands),
        TwemojiPickerSection(title: TwemojiL10n("twemoji.category.animals"), emojis: animals),
        TwemojiPickerSection(title: TwemojiL10n("twemoji.category.food"), emojis: food),
        TwemojiPickerSection(title: TwemojiL10n("twemoji.category.activity"), emojis: activity),
        TwemojiPickerSection(title: TwemojiL10n("twemoji.category.travel"), emojis: travel),
        TwemojiPickerSection(title: TwemojiL10n("twemoji.category.objects"), emojis: objects),
        TwemojiPickerSection(title: TwemojiL10n("twemoji.category.symbols"), emojis: symbols),
    ]

    // MARK: - Emoji Data

    private static let smileys = [
        "😀", "😃", "😄", "😁", "😆", "😅", "🤣", "😂",
        "🙂", "🙃", "😉", "😊", "😇", "🥰", "😍", "🤩",
        "😘", "😗", "😚", "😙", "🥲", "😋", "😛", "😜",
        "🤪", "😝", "🤑", "🤗", "🤭", "🤫", "🤔", "🫡",
        "🤐", "🤨", "😐", "😑", "😶", "😏", "😒", "🙄",
        "😬", "🤥", "😌", "😔", "😪", "🤤", "😴", "😷",
        "🤒", "🤕", "🤢", "🤮", "🥴", "😵", "🤯", "🥸",
        "😎", "🤓", "🧐", "😕", "😟", "🙁", "☹️", "😮",
        "😯", "😲", "😳", "🥺", "🥹", "😦", "😧", "😨",
        "😰", "😥", "😢", "😭", "😱", "😖", "😣", "😞",
        "😓", "😩", "😫", "🥱", "😤", "😡", "😠", "🤬",
        "😈", "👿", "💀", "☠️", "💩", "🤡", "👹", "👺",
        "👻", "👽", "👾", "🤖", "🎃", "😺", "😸", "😹",
        "😻", "😼", "😽", "🙀", "😿", "😾",
    ]

    private static let hearts = [
        "❤️", "🧡", "💛", "💚", "💙", "💜", "🖤", "🤍",
        "🤎", "💔", "❤️‍🔥", "❤️‍🩹", "💕", "💞", "💓", "💗",
        "💖", "💘", "💝", "💟", "♥️", "💋", "💌", "💐",
    ]

    private static let hands = [
        "👋", "🤚", "🖐️", "✋", "🖖", "🫱", "🫲", "🫳",
        "🫴", "👌", "🤌", "🤏", "✌️", "🤞", "🫰", "🤟",
        "🤘", "🤙", "👈", "👉", "👆", "🖕", "👇", "☝️",
        "🫵", "👍", "👎", "✊", "👊", "🤛", "🤜", "👏",
        "🙌", "🫶", "👐", "🤲", "🤝", "🙏", "✍️", "💅",
    ]

    private static let animals = [
        "🐶", "🐱", "🐭", "🐹", "🐰", "🦊", "🐻", "🐼",
        "🐻‍❄️", "🐨", "🐯", "🦁", "🐮", "🐷", "🐸", "🐵",
        "🐔", "🐧", "🐦", "🐤", "🦆", "🦅", "🦉", "🦇",
        "🐺", "🐗", "🐴", "🦄", "🐝", "🪱", "🐛", "🦋",
        "🐌", "🐞", "🐜", "🪰", "🪲", "🪳", "🦟", "🦗",
        "🐙", "🦑", "🦐", "🦞", "🦀", "🐡", "🐠", "🐟",
        "🐬", "🐳", "🐋", "🦈", "🐊", "🐅", "🐆", "🦓",
        "🌸", "💮", "🌹", "🥀", "🌺", "🌻", "🌼", "🌷",
    ]

    private static let food = [
        "🍎", "🍐", "🍊", "🍋", "🍌", "🍉", "🍇", "🍓",
        "🫐", "🍈", "🍒", "🍑", "🥭", "🍍", "🥥", "🥝",
        "🍔", "🍟", "🍕", "🌭", "🥪", "🌮", "🌯", "🫔",
        "🍝", "🍜", "🍲", "🍛", "🍣", "🍱", "🥟", "🍿",
        "🍵", "☕", "🍺", "🍷", "🥂", "🧋", "🥤", "🍹",
    ]

    private static let activity = [
        "⚽", "🏀", "🏈", "⚾", "🎾", "🏐", "🎱", "🏓",
        "🏸", "🥊", "🎯", "⛳", "🏹", "🎣", "🛹", "🎿",
        "🏋️", "🤸", "🎭", "🎨", "🎬", "🎤", "🎧", "🎼",
        "🎹", "🥁", "🎷", "🎺", "✨", "🎈", "🎉", "🎊",
        "🎃", "🎄", "🎆", "🎇", "🧨", "🎋", "🎍", "🧧",
    ]

    private static let travel = [
        "🚗", "🚕", "🚌", "🏎️", "🚓", "🚑", "🚒", "🚲",
        "✈️", "🚀", "🛸", "🚁", "⛵", "🚢", "🏠", "🏢",
        "⛪", "🕌", "🗼", "🗽", "🗿", "🌍", "🌎", "🌏",
        "☀️", "🌤️", "⛅", "🌧️", "⛈️", "🌈", "❄️", "🔥",
        "🌊", "🏔️", "⛰️", "🌋", "🏝️", "🌪️", "🌫️", "☃️",
    ]

    private static let objects = [
        "📱", "💻", "⌨️", "🖥️", "📷", "📹", "🎥", "📺",
        "⏰", "⌚", "💡", "🔦", "📔", "📕", "📖", "📚",
        "✏️", "📝", "💼", "📁", "🔑", "🗝️", "🔒", "🔓",
        "🔨", "🔧", "⚙️", "💊", "🩹", "👓", "🕶️", "👔",
        "👕", "👖", "👗", "👜", "🎒", "👟", "👠", "💎",
    ]

    private static let symbols = [
        "💯", "🔴", "🟠", "🟡", "🟢", "🔵", "🟣", "⚫",
        "⚪", "🟤", "🔶", "🔷", "🔺", "🔻", "💠", "🔘",
        "✅", "☑️", "❌", "❎", "➕", "➖", "➗", "✖️",
        "♾️", "‼️", "⁉️", "❓", "❗", "〰️", "💲", "⚜️",
        "♻️", "⚠️", "🚫", "📛", "♈", "♉", "♊", "♋",
        "♌", "♍", "♎", "♏", "♐", "♑", "♒", "♓",
    ]
}
