//
//  PickerDemoView.swift
//  AppTwemojiSample
//
//  Created by Claude on 2026-03-13.
//

import SwiftUI
import TwemojiKit

@available(iOS 14.0, *)
struct PickerDemoView: View {
    @StateObject private var recentStore = TwemojiRecentStore()
    @State private var showPicker = false
    @State private var selectedEmoji: String = ""
    @State private var parsedImages: [TwemojiImage] = []

    var body: some View {
        NavigationView {
            VStack(spacing: 32) {
                Spacer()

                // Selected emoji display
                if !selectedEmoji.isEmpty {
                    VStack(spacing: 12) {
                        TwemojiCellView(emoji: selectedEmoji, size: 80)

                        if let twemojiImage = parsedImages.first {
                            Text(twemojiImage.code)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                                .background(Color(.systemGray6))
                                .cornerRadius(6)
                        }
                    }
                } else {
                    VStack(spacing: 8) {
                        Image(systemName: "face.smiling")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary.opacity(0.4))
                        Text(TwemojiL10n("twemoji.picker.no_selection"))
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                // Open picker button
                Button {
                    showPicker = true
                } label: {
                    HStack {
                        Image(systemName: "face.smiling.inverse")
                        Text(TwemojiL10n("twemoji.picker.choose"))
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.accentColor)
                    .cornerRadius(12)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
            .navigationTitle("TwemojiKit Demo")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showPicker) {
                pickerSheet
            }
        }
    }

    private var pickerSheet: some View {
        NavigationView {
            TwemojiPickerView(
                sections: [
                    TwemojiPickerSection(title: TwemojiL10n("twemoji.category.smileys"), emojis: Self.smileys),
                    TwemojiPickerSection(title: TwemojiL10n("twemoji.category.hearts"), emojis: Self.hearts),
                    TwemojiPickerSection(title: TwemojiL10n("twemoji.category.animals"), emojis: Self.animals),
                    TwemojiPickerSection(title: TwemojiL10n("twemoji.category.food"), emojis: Self.food),
                    TwemojiPickerSection(title: TwemojiL10n("twemoji.category.activity"), emojis: Self.activity),
                    TwemojiPickerSection(title: TwemojiL10n("twemoji.category.travel"), emojis: Self.travel),
                    TwemojiPickerSection(title: TwemojiL10n("twemoji.category.objects"), emojis: Self.objects),
                ],
                recentEmojis: recentStore.emojis,
                columns: 6,
                onSelect: { emoji in
                    selectedEmoji = emoji
                    recentStore.record(emoji)
                    parsedImages = Twemoji.shared.parse(emoji)
                    showPicker = false
                }
            )
            .navigationTitle(TwemojiL10n("twemoji.picker.title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(TwemojiL10n("twemoji.picker.cancel")) {
                        showPicker = false
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(TwemojiL10n("twemoji.picker.clear")) {
                        recentStore.clear()
                    }
                    .font(.subheadline)
                }
            }
        }
    }

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

    private static let animals = [
        "🐶", "🐱", "🐭", "🐹", "🐰", "🦊", "🐻", "🐼",
        "🐻‍❄️", "🐨", "🐯", "🦁", "🐮", "🐷", "🐸", "🐵",
        "🐔", "🐧", "🐦", "🐤", "🦆", "🦅", "🦉", "🦇",
        "🐺", "🐗", "🐴", "🦄", "🐝", "🪱", "🐛", "🦋",
        "🐌", "🐞", "🐜", "🪰", "🪲", "🪳", "🦟", "🦗",
        "🐙", "🦑", "🦐", "🦞", "🦀", "🐡", "🐠", "🐟",
        "🐬", "🐳", "🐋", "🦈", "🐊", "🐅", "🐆", "🦓",
        "🦍", "🦧", "🐘", "🦛", "🦏", "🐪", "🐫", "🦒",
        "🌸", "💮", "🏵️", "🌹", "🥀", "🌺", "🌻", "🌼",
        "🌷", "🌱", "🪴", "🌲", "🌳", "🌴", "🌵", "🍀",
    ]

    private static let food = [
        "🍎", "🍐", "🍊", "🍋", "🍌", "🍉", "🍇", "🍓",
        "🫐", "🍈", "🍒", "🍑", "🥭", "🍍", "🥥", "🥝",
        "🍅", "🍆", "🥑", "🥦", "🥬", "🥒", "🌶️", "🫑",
        "🍔", "🍟", "🍕", "🌭", "🥪", "🌮", "🌯", "🫔",
        "🥗", "🍝", "🍜", "🍲", "🍛", "🍣", "🍱", "🥟",
        "🍿", "🧂", "🥤", "🍵", "☕", "🍺", "🍷", "🥂",
    ]

    private static let activity = [
        "⚽", "🏀", "🏈", "⚾", "🥎", "🎾", "🏐", "🏉",
        "🥏", "🎱", "🪀", "🏓", "🏸", "🏒", "🥊", "🥋",
        "🎯", "⛳", "🪁", "🏹", "🎣", "🎽", "🛹", "🛼",
        "🎿", "⛷️", "🏂", "🪂", "🏋️", "🤸", "🎭", "🎨",
        "🎬", "🎤", "🎧", "🎼", "🎹", "🥁", "🎷", "🎺",
        "🎃", "🎄", "🎆", "🎇", "🧨", "✨", "🎈", "🎉",
        "🎊", "🎋", "🎍", "🎎", "🎏", "🎐", "🎑", "🧧",
    ]

    private static let travel = [
        "🚗", "🚕", "🚌", "🚎", "🏎️", "🚓", "🚑", "🚒",
        "🚐", "🛻", "🚚", "🚛", "🚜", "🏍️", "🛵", "🚲",
        "✈️", "🚀", "🛸", "🚁", "⛵", "🚢", "🏠", "🏡",
        "🏢", "🏣", "🏤", "🏥", "🏦", "🏨", "🏩", "🏪",
        "⛪", "🕌", "🛕", "🕍", "⛩️", "🗼", "🗽", "🗿",
        "🌍", "🌎", "🌏", "🏔️", "⛰️", "🌋", "🗻", "🏝️",
        "☀️", "🌤️", "⛅", "🌥️", "🌦️", "🌧️", "⛈️", "🌩️",
        "🌈", "☁️", "🌪️", "🌫️", "❄️", "☃️", "⛄", "🔥",
    ]

    private static let objects = [
        "📱", "💻", "⌨️", "🖥️", "🖨️", "🖱️", "💿", "📷",
        "📹", "🎥", "📺", "📻", "🎙️", "⏰", "⌚", "📡",
        "🔋", "💡", "🔦", "🕯️", "📔", "📕", "📖", "📚",
        "✏️", "🖊️", "🖋️", "📝", "💼", "📁", "📂", "📅",
        "📌", "📎", "🔑", "🗝️", "🔒", "🔓", "🔨", "🪓",
        "⛏️", "🔧", "🔩", "⚙️", "🧲", "💊", "🩹", "🩺",
        "👓", "🕶️", "👔", "👕", "👖", "👗", "👘", "👙",
        "👚", "👛", "👜", "👝", "🎒", "👞", "👟", "👠",
    ]
}
