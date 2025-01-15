//
//  ViewController.swift
//  TextKitEditor2
//
//  Created by Laxmi Narayana Koyyana on 29/11/24.
//

import UIKit

class ViewController: UIViewController {

    var customTextView : TextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create the custom text view
        let textLayoutManager = NSTextLayoutManager()
        let textContainer = NSTextContainer()
        textLayoutManager.textContainer = textContainer
        let textContentStorage = NSTextContentStorage()
        textContentStorage.addTextLayoutManager(textLayoutManager)
        
        customTextView = TextView(frame: .zero, textContainer: textContainer)
        customTextView.translatesAutoresizingMaskIntoConstraints = false
        customTextView.textContentStorage = textContentStorage
        
        view.addSubview(customTextView)

        NSLayoutConstraint.activate([
            customTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            customTextView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            customTextView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
      
}

