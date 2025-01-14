//
//  iPhoneKeyboardLayoutProvider.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2021-02-02.
//  Copyright © 2021-2024 Daniel Saidi. All rights reserved.
//

import SwiftUI

/// This layout provider provides iPhone-specific layouts.
///
/// This provider will by default generate a `QWERTY` layout,
/// which is the standard layout for many locales.
///
/// You can inherit this provider and customize it as needed.
open class iPhoneKeyboardLayoutProvider: BaseKeyboardLayoutProvider {


    // MARK: - Overrides

    open override func actions(
        for inputs: InputSet.Rows,
        context: KeyboardContext
    ) -> KeyboardAction.Rows {
        let actions = super.actions(for: inputs, context: context)
        guard isExpectedActionSet(actions, context: context) else { return actions }
        var result = KeyboardAction.Rows()
        result.append(topLeadingActions(for: actions, context: context) + actions[0] + topTrailingActions(for: actions, context: context))
        result.append(middleLeadingActions(for: actions, context: context) + actions[1] + middleTrailingActions(for: actions, context: context))
        if actions.count == 3 {
            result.append(lowerLeadingActions(for: actions, context: context) + actions[2] + lowerTrailingActions(for: actions, context: context))
        } else {
            result.append(middleLeadingActions(for: actions, context: context) + actions[2] + middleTrailingActions(for: actions, context: context))
            result.append(lowerLeadingActions(for: actions, context: context) + actions[3] + lowerTrailingActions(for: actions, context: context))
        }
        result.append(bottomActions(for: context))
        return result
    }

    open override func itemSizeWidth(
        for action: KeyboardAction,
        row: Int,
        index: Int,
        context: KeyboardContext
    ) -> KeyboardLayout.ItemWidth {
        switch action {
        case context.keyboardDictationReplacement: bottomSystemButtonWidth(for: context)
        case .character: isLastNumericInputRow(row, for: context) ? lastSymbolicInputWidth(for: context) : .input
        case .backspace: lowerSystemButtonWidth(for: context)
        case .keyboardType: bottomSystemButtonWidth(for: context)
        case .nextKeyboard: bottomSystemButtonWidth(for: context)
        case .primary: .percentage(isPortrait(context) ? 0.25 : 0.195)
        case .shift: lowerSystemButtonWidth(for: context)
        default: .available
        }
    }


    // MARK: - iPhone Specific

    /// The leading actions to add to the top input row.
    open func topLeadingActions(
        for actions: KeyboardAction.Rows,
        context: KeyboardContext
    ) -> KeyboardAction.Row {
        guard shouldAddUpperMarginActions(for: actions, context: context) else { return [] }
        return [actions[0].leadingCharacterMarginAction]
    }

    /// The trailing actions to add to the top input row.
    open func topTrailingActions(
        for actions: KeyboardAction.Rows,
        context: KeyboardContext
    ) -> KeyboardAction.Row {
        guard shouldAddUpperMarginActions(for: actions, context: context) else { return [] }
        return [actions[0].trailingCharacterMarginAction]
    }

    /// The leading actions to add to the middle input row.
    open func middleLeadingActions(
        for actions: KeyboardAction.Rows,
        context: KeyboardContext
    ) -> KeyboardAction.Row {
        guard shouldAddMiddleMarginActions(for: actions, context: context) else { return [] }
        return [actions[1].leadingCharacterMarginAction]
    }

    /// The trailing actions to add to the middle input row.
    open func middleTrailingActions(
        for actions: KeyboardAction.Rows,
        context: KeyboardContext
    ) -> KeyboardAction.Row {
        guard shouldAddMiddleMarginActions(for: actions, context: context) else { return [] }
        return [actions[1].trailingCharacterMarginAction]
    }

    /// The leading actions to add to the lower input row.
    open func lowerLeadingActions(
        for actions: KeyboardAction.Rows,
        context: KeyboardContext
    ) -> KeyboardAction.Row {
        guard isExpectedActionSet(actions, context: context), let margin = actions.last?.leadingCharacterMarginAction else { return [] }
        guard let switcher = keyboardSwitchActionForBottomInputRow(for: context) else { return [] }
        if context.keyboardType == .numeric || context.keyboardType == .symbolic {
            return [switcher, margin]
        } else {
            return [switcher]
        }
    }

    /// The trailing actions to add to the lower input row.
    open func lowerTrailingActions(
        for actions: KeyboardAction.Rows,
        context: KeyboardContext
    ) -> KeyboardAction.Row {
        guard isExpectedActionSet(actions, context: context), let margin = actions.last?.trailingCharacterMarginAction else { return [] }
        if context.keyboardType == .numeric || context.keyboardType == .symbolic {
            return [margin, .backspace]
        } else {
            return [.backspace]
        }
    }

    /// The width of system buttons on the lower input row.
    open func lowerSystemButtonWidth(
        for context: KeyboardContext
    ) -> KeyboardLayout.ItemWidth {
        if context.isAlphabetic(.tatar) { return .input }
        return .input // percentage(0.13)
    }

    /// The actions to add to the bottom system row.
    open func bottomActions(
        for context: KeyboardContext
    ) -> KeyboardAction.Row {
        var result = KeyboardAction.Row()
        let needsInputSwitch = context.needsInputModeSwitchKey
        let needsDictation = context.needsInputModeSwitchKey
        if let action = keyboardSwitchActionForBottomRow(for: context) { result.append(action) }
        if needsInputSwitch { result.append(.nextKeyboard) }
        if !needsInputSwitch { result.append(.keyboardType(.emojis)) }
        let dictationReplacement = context.keyboardDictationReplacement
        if isPortrait(context), needsDictation, let action = dictationReplacement { result.append(action) }
        result.append(.space)
        #if os(iOS) || os(tvOS) || os(visionOS)
        if context.textDocumentProxy.keyboardType == .emailAddress {
            result.append(.character("@"))
            result.append(.character("."))
        }
        if context.textDocumentProxy.returnKeyType == .go {
            result.append(.character("."))
        }
        #endif
        result.append(keyboardReturnAction(for: context))
        if !isPortrait(context), needsDictation, let action = dictationReplacement { result.append(action) }
        return result
    }

    /// The width of system buttons on the bottom system row.
    open func bottomSystemButtonWidth(
        for context: KeyboardContext
    ) -> KeyboardLayout.ItemWidth {
        .percentage(isPortrait(context) ? 0.123 : 0.095)
    }

    /// Whether to add margins to the middle row.
    open func shouldAddMiddleMarginActions(
        for actions: KeyboardAction.Rows,
        context: KeyboardContext
    ) -> Bool {
        guard isExpectedActionSet(actions, context: context) else { return false }
        return actions[0].count > actions[1].count
    }

    /// Whether to add margins to the upper row.
    open func shouldAddUpperMarginActions(
        for actions: KeyboardAction.Rows,
        context: KeyboardContext
    ) -> Bool {
        false
    }
}

private extension iPhoneKeyboardLayoutProvider {

    func isExpectedActionSet(_ actions: KeyboardAction.Rows, context: KeyboardContext) -> Bool {
        if [.numeric, .symbolic].contains(context.keyboardType) {
            return actions.count == 3
        }
        return actions.count == 3 // TODO, INFO: Shrinked ugly 4 rows error when set actions.count == 3, so set actions.count == 4
    }
    
    func isExpectedNumericActionSet(
        _ actions: KeyboardAction.Rows
    ) -> Bool {
        return actions.count == 3 // TODO, INFO: Shrinked ugly 3 rows error when set actions.count == 4, so set actions.count == 3
    }
    
    func isExpectedLetterActionSet(
        _ actions: KeyboardAction.Rows
    ) -> Bool {
        return actions.count == 3 // TODO, INFO: Shrinked ugly 4 rows error when set actions.count == 3, so set actions.count == 4
    }

    func isPortrait(
        _ context: KeyboardContext
    ) -> Bool {
        context.interfaceOrientation.isPortrait
    }

    /// The width of the last symbolic row input button.
    func lastSymbolicInputWidth(
        for context: KeyboardContext
    ) -> KeyboardLayout.ItemWidth {
        .percentage(0.14)
    }

    /// Whether or not a row is the last input/symbolic row.
    func isLastNumericInputRow(
        _ row: Int,
        for context: KeyboardContext
    ) -> Bool {
        let isNumeric = context.keyboardType == .numeric
        let isSymbolic = context.keyboardType == .symbolic
        guard isNumeric || isSymbolic else { return false }
        return row == 2 // Index 2 is the "wide keys" row
    }
}


// MARK: - KeyboardContext

private extension KeyboardContext {

    /// This function makes the context checks above shorter.
    func `is`(_ locale: KeyboardLocale) -> Bool {
        hasKeyboardLocale(locale)
    }

    /// This function makes the context checks above shorter.
    func isAlphabetic(_ locale: KeyboardLocale) -> Bool {
        hasKeyboardLocale(locale) && keyboardType.isAlphabetic
    }
}
