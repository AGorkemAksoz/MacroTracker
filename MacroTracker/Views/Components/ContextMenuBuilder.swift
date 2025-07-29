//
//  ContextMenuBuilder.swift
//  MacroTracker
//
//  Created by Ali Görkem Aksöz on 28.07.2025.
//


import SwiftUI

// MARK: - Context Menu Action Protocol

/// Protocol for defining context menu actions
protocol ContextMenuAction {
    var title: String { get }
    var icon: String { get }
    var role: ButtonRole? { get }
    var isEnabled: Bool { get }
}

/// Default implementation for context menu actions
extension ContextMenuAction {
    var role: ButtonRole? { nil }
    var isEnabled: Bool { true }
}

// MARK: - Standard Context Menu Actions

/// Standard context menu actions
struct ViewDetailsAction: ContextMenuAction {
    let title = "View Details"
    let icon = "eye"
}

struct DeleteAction: ContextMenuAction {
    let title: String
    let icon = "trash"
    let role: ButtonRole? = .destructive
    
    init(title: String = "Delete") {
        self.title = title
    }
}

struct EditAction: ContextMenuAction {
    let title = "Edit"
    let icon = "pencil"
}

struct ShareAction: ContextMenuAction {
    let title = "Share"
    let icon = "square.and.arrow.up"
}

// MARK: - Context Menu Builder

/// A builder for creating context menus
struct ContextMenuBuilder<Item> {
    let item: Item
    let actions: [ContextMenuAction]
    let onAction: (ContextMenuAction, Item) -> Void
    
    init(
        item: Item,
        actions: [ContextMenuAction],
        onAction: @escaping (ContextMenuAction, Item) -> Void
    ) {
        self.item = item
        self.actions = actions
        self.onAction = onAction
    }
    
    func build() -> some View {
        ForEach(Array(actions.enumerated()), id: \.offset) { _, action in
            Button(role: action.role) {
                onAction(action, item)
            } label: {
                Label(action.title, systemImage: action.icon)
            }
            .disabled(!action.isEnabled)
        }
    }
}

// MARK: - View Extension

extension View {
    /// Adds a context menu with actions to the view
    /// - Parameters:
    ///   - item: The item associated with this context menu
    ///   - actions: Array of context menu actions
    ///   - onAction: Closure called when an action is selected
    /// - Returns: A view with the context menu
    func contextMenu<Item>(
        item: Item,
        actions: [ContextMenuAction],
        onAction: @escaping (ContextMenuAction, Item) -> Void
    ) -> some View {
        self.contextMenu {
            ContextMenuBuilder(item: item, actions: actions, onAction: onAction).build()
        }
    }
    
    /// Adds a standard view details and delete context menu
    /// - Parameters:
    ///   - item: The item associated with this context menu
    ///   - onViewDetails: Closure called when view details is selected
    ///   - onDelete: Closure called when delete is selected
    ///   - deleteTitle: Custom title for delete action
    /// - Returns: A view with the standard context menu
    func standardContextMenu<Item>(
        item: Item,
        onViewDetails: @escaping (Item) -> Void,
        onDelete: @escaping (Item) -> Void,
        deleteTitle: String = "Delete"
    ) -> some View {
        contextMenu(
            item: item,
            actions: [
                ViewDetailsAction(),
                DeleteAction(title: deleteTitle)
            ]
        ) { action, item in
            switch action {
            case is ViewDetailsAction:
                onViewDetails(item)
            case is DeleteAction:
                onDelete(item)
            default:
                break
            }
        }
    }
}
