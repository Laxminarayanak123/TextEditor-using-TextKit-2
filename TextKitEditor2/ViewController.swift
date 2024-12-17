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
//        customTextView.textContentStorage = textContentStorage
        
        view.addSubview(customTextView)

        NSLayoutConstraint.activate([
            customTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 8),
            customTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -8),
            customTextView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            customTextView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
       
//        textContentStorage.replaceContents(in: textLayoutManager.documentRange, with: [NSTextParagraph(attributedString: NSAttributedString(string: "happy"))])
        
        
    }
    
    
}

extension NSRange {
    init(_ textrange: NSTextRange, contentManager: NSTextContentManager){
        let loc = contentManager.offset(from: contentManager.documentRange.location, to: textrange.location)
        let length = contentManager.offset(from: textrange.location, to: textrange.endLocation)
        self.init(location: loc, length: length)
    }
}


extension NSTextRange{
    convenience init?(_ range: NSRange, contentManager: NSTextContentManager){
        let location = contentManager.location(contentManager.documentRange.location, offsetBy: range.location)
        let end = contentManager.location(location!, offsetBy: range.length)
        
        self.init(location: location!, end: end)
    }
}
