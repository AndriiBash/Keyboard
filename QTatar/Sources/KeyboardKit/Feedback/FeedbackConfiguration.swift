//
//  FeedbackConfiguration.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2021-04-01.
//  Copyright © 2021-2024 Daniel Saidi. All rights reserved.
//

import Combine
import Foundation

/// This class can be used to configure the kind of feedback
/// a keyboard should give to the user.
///
/// You can setup the ``audio`` and ``haptic`` properties to
/// customize the feedback behavior.
///
/// KeyboardKit creates an instance of the class and injects
/// it into ``KeyboardInputViewController/state`` on launch.
public class FeedbackConfiguration: ObservableObject {
    
    /// Create a keyboard configuration instance.
    ///
    /// - Parameters:
    ///   - audioConfiguration: The configuration to use for audio feedback, by deafult `.enabled`.
    ///   - hapticConfiguration: The configuration to use for haptic feedback, by deafult `.minimal`.
    public init(
        audio: AudioFeedback.Configuration = .enabled,
        haptic: HapticFeedback.Configuration = .minimal
    ) {
        self.audio = audio
        self.haptic = haptic
        enabledAudio = audio == .disabled ? .enabled : audio
        enabledHaptic = haptic == .disabled ? .enabled : haptic
    }
    
    /// The configuration to use for audio feedback.
    @Published
    public var audio: AudioFeedback.Configuration {
        didSet {
            guard audio != .disabled else { return }
            enabledAudio = audio
        }
    }
    
    /// The configuration to use for haptic feedback.
    @Published
    public var haptic: HapticFeedback.Configuration {
        didSet {
            guard haptic != .disabled else { return }
            enabledHaptic = haptic
        }
    }
    
    private var enabledAudio: AudioFeedback.Configuration
    private var enabledHaptic: HapticFeedback.Configuration
}

public extension FeedbackConfiguration {
    
    /// This specifies a standard feedback configuration.
    static let standard = FeedbackConfiguration()
}

public extension FeedbackConfiguration {

    /// Get or set whether or not audio feedback is enabled.
    var isAudioFeedbackEnabled: Bool {
        get { audio == enabledAudio }
        set { audio = newValue ? enabledAudio : .disabled }
    }

    /// Get or set whether or not haptic feedback is enabled.
    var isHapticFeedbackEnabled: Bool {
        get { haptic == enabledHaptic }
        set { haptic = newValue ? enabledHaptic : .disabled }
    }

    /// Toggle audio feedback between enabled and disabled.
    func toggleIsAudioFeedbackEnabled() {
        isAudioFeedbackEnabled.toggle()
    }

    /// Toggle haptic feedback between enabled and disabled.
    func toggleIsHapticFeedbackEnabled() {
        isHapticFeedbackEnabled.toggle()
    }
}
