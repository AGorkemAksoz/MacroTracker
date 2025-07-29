//
//  ConfirmationAlertManager.swift
//  MacroTracker
//
//  Created by Ali Görkem Aksöz on 28.07.2025.
//

import SwiftUI

// MARK: - Generic Confirmation Alert Manager

/// A generic confirmation alert manager that can handle any type of item
class ConfirmationAlertManager<Item>: ObservableObject {
    @Published var showingAlert = false
    @Published var itemToDelete: Item?
    
    private let deleteAction: (Item) -> Void
    private let title: String
    private let messageBuilder: (Item) -> String
    
    init(
        title: String = "Confirm Delete",
        messageBuilder: @escaping (Item) -> String,
        deleteAction: @escaping (Item) -> Void
    ) {
        self.title = title
        self.messageBuilder = messageBuilder
        self.deleteAction = deleteAction
    }
    
    func showDeleteConfirmation(for item: Item) {
        itemToDelete = item
        showingAlert = true
    }
    
    func confirmDelete() {
        if let item = itemToDelete {
            deleteAction(item)
        }
        itemToDelete = nil
    }
    
    func cancelDelete() {
        itemToDelete = nil
    }
    
    var alertMessage: String {
        itemToDelete.map(messageBuilder) ?? ""
    }
}

// MARK: - View Extension

//extension View {
//    /// Adds a generic confirmation alert to the view
//    /// - Parameters:
//    ///   - manager: The alert manager instance
//    ///   - title: Alert title (optional, uses manager's default)
//    ///   - confirmTitle: Confirm button title
//    ///   - cancelTitle: Cancel button title
//    /// - Returns: A view with the confirmation alert
//    func genericConfirmationAlert<Item>(
//        manager: ConfirmationAlertManager<Item>,
//        title: String? = nil,
//        confirmTitle: String = "Delete",
//        cancelTitle: String = "Cancel"
//    ) -> some View {
//        self.confirmationAlert(
//            isPresented: $manager.showingAlert,
//            alert: ConfirmationAlert(
//                title: title ?? manager.title,
//                message: manager.alertMessage,
//                confirmButtonTitle: confirmTitle,
//                cancelButtonTitle: cancelTitle
//            ) {
//                manager.confirmDelete()
//            }
//        )
//    }
//}
