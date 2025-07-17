//
//  ConfirmationAlert.swift
//  MacroTracker
//
//  Created by Gorkem on 13.06.2025.
//

import SwiftUI

/// A reusable confirmation alert component that follows clean architecture principles.
/// 
/// This component provides a standardized way to present confirmation dialogs throughout the app,
/// ensuring consistent UX and reducing code duplication.
///
/// ## Usage Example:
/// ```swift
/// @State private var showingAlert = false
/// @State private var itemToDelete: SomeItem?
///
/// var body: some View {
///     Button("Delete") {
///         itemToDelete = someItem
///         showingAlert = true
///     }
///     .confirmationAlert(
///         isPresented: $showingAlert,
///         alert: ConfirmationAlert(
///             title: "Delete Item",
///             message: "Are you sure you want to delete this item?",
///             confirmButtonTitle: "Delete",
///             cancelButtonTitle: "Cancel"
///         ) {
///             // Perform delete action
///             deleteItem(itemToDelete)
///             itemToDelete = nil
///         }
///     )
/// }
/// ```
struct ConfirmationAlert {
    /// The title displayed in the alert
    let title: String
    
    /// The message displayed in the alert body
    let message: String
    
    /// The text for the confirmation button (defaults to "Confirm")
    let confirmButtonTitle: String
    
    /// The text for the cancel button (defaults to "Cancel")
    let cancelButtonTitle: String
    
    /// The action to perform when the user confirms
    let confirmAction: () -> Void
    
    /// Creates a new confirmation alert
    /// - Parameters:
    ///   - title: The alert title (defaults to "Confirm Action")
    ///   - message: The alert message
    ///   - confirmButtonTitle: Text for confirm button (defaults to "Confirm")
    ///   - cancelButtonTitle: Text for cancel button (defaults to "Cancel")
    ///   - confirmAction: Closure to execute when user confirms
    init(
        title: String = "Confirm Action",
        message: String,
        confirmButtonTitle: String = "Confirm",
        cancelButtonTitle: String = "Cancel",
        confirmAction: @escaping () -> Void
    ) {
        self.title = title
        self.message = message
        self.confirmButtonTitle = confirmButtonTitle
        self.cancelButtonTitle = cancelButtonTitle
        self.confirmAction = confirmAction
    }
}

/// View modifier to add a confirmation alert
struct ConfirmationAlertModifier: ViewModifier {
    @Binding var isPresented: Bool
    let alert: ConfirmationAlert
    
    func body(content: Content) -> some View {
        content
            .alert(alert.title, isPresented: $isPresented) {
                Button(alert.cancelButtonTitle, role: .cancel) { }
                Button(alert.confirmButtonTitle, role: .destructive) {
                    alert.confirmAction()
                }
            } message: {
                Text(alert.message)
            }
    }
}

/// View extension for easy usage
extension View {
    /// Adds a confirmation alert to the view
    /// - Parameters:
    ///   - isPresented: Binding to control alert visibility
    ///   - alert: The confirmation alert configuration
    /// - Returns: A view with the confirmation alert modifier
    func confirmationAlert(
        isPresented: Binding<Bool>,
        alert: ConfirmationAlert
    ) -> some View {
        modifier(ConfirmationAlertModifier(isPresented: isPresented, alert: alert))
    }
}
