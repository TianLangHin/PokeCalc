//
//  ShareViewController.swift
//  PokeCalcShare
//
//  Created by Tian Lang Hin on 9/10/2025.
//

import SwiftUI
import UIKit
import UniformTypeIdentifiers

class ShareViewController: UIViewController {
    /// Main functionality that loads a given View the moment the Share extension starts.
    override func viewDidLoad() {
        // First call the parent method implementation.
        super.viewDidLoad()

        // Then, grab the item from the share system extension.
        guard
            let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem,
            let itemProvider = extensionItem.attachments?.first else {
            self.close()
            return
        }

        // Next, check the type identifier. This app will only support copying text.
        // This will cause an error in the executable, but works correctly.
        let textDataType = UTType.plainText.identifier
        guard itemProvider.hasItemConformingToTypeIdentifier(textDataType) else {
            self.close()
            return
        }

        // Load the item from item provider, recognising it should be text.
        itemProvider.loadItem(forTypeIdentifier: textDataType, options: nil) { (providedText, error) in
            if error != nil {
                self.close()
                return
            }
            
            // Try decoding the attached data as a String. If unsuccessful, close the share extension.
            guard let text = providedText as? String else {
                self.close()
                return
            }
            
            // If all the above checks worked, then the View is to be displayed.
            DispatchQueue.main.async {
                // This will host the SwiftUI View
                let contentView = UIHostingController(rootView: ShareExtensionView(text: text))
                self.addChild(contentView)
                self.view.addSubview(contentView.view)
                // This will set up constraints to ensure the SwiftUI View looks correct.
                contentView.view.translatesAutoresizingMaskIntoConstraints = false
                contentView.view.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
                contentView.view.bottomAnchor.constraint (equalTo: self.view.bottomAnchor).isActive = true
                contentView.view.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
                contentView.view.rightAnchor.constraint (equalTo: self.view.rightAnchor).isActive = true
            }
        }

        // Finally, add the functionality to the Share Extension to allow for closing the View.
        NotificationCenter.default.addObserver(forName: NSNotification.Name("close"), object: nil, queue: nil) { _ in
            DispatchQueue.main.async {
                self.close()
            }
        }
    }
    
    /// Close the Share Extension
    func close() {
        self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
    }
}
