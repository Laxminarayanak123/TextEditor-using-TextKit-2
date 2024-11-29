//
//  TextView.swift
//  TextKitEditor2
//
//  Created by Laxmi Narayana Koyyana on 29/11/24.
//

import UIKit

class TextView : UITextView, UITextViewDelegate{
    override init(frame: CGRect, textContainer: NSTextContainer?) {

        super.init(frame: frame, textContainer: textContainer)
        
        setupTextView()
        inputAccessoryView = createToolbar()
        keyboardDismissMode = .interactiveWithAccessory
        alwaysBounceVertical = true
        delegate = self
        isEditable = true
        isScrollEnabled = true
        backgroundColor = UIColor.systemBackground
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setupTextView() {
        // Create the NSTextStorage with styled text
        let styledText = NSMutableAttributedString(
            string: "Welcome to TextKit customization! This is an example of using textContainer, layoutManager, and textStorage. \n",
            attributes: [
                .font: UIFont.systemFont(ofSize: 18),
                .foregroundColor: UIColor.label
            ]
        )

        styledText.addAttribute(
            .foregroundColor,
            value: UIColor.systemBlue,
            range: NSRange(location: 0, length: 7)
        )
        
      
        let textList = NSTextList(markerFormat: .decimal, options: 0)
        let textListParagraphStyle = NSMutableParagraphStyle()
        textListParagraphStyle.textLists = [textList]
        let attributes = [NSAttributedString.Key.paragraphStyle: textListParagraphStyle]
        let _ = NSMutableAttributedString(string: "1",attributes: attributes)
        
//        textStorage.append(item)

//        let textList2 = NSTextList(markerFormat: .decimal, options: 0)
//        let textListParagraphStyle2 = NSMutableParagraphStyle()
//        textListParagraphStyle2.textLists = [textList, textList2]
//        let attributes2 = [NSAttributedString.Key.paragraphStyle: textListParagraphStyle2]
//
//        let item2 = NSAttributedString(string: "aaaaaa\nbbbbbb", attributes: attributes2)
//        textStorage.append(item2)
        
        }
    
    
    private func createToolbar() -> UIToolbar {
            let toolbar = UIToolbar()
            toolbar.items = [
//                UIBarButtonItem(title: "Bold", style: .plain, target: self, action: #selector(applyBold)),
//                UIBarButtonItem(title: "Italic", style: .plain, target: self, action: #selector(applyItalic)),
//                UIBarButtonItem(title: "Underline", style: .plain, target: self, action: #selector(applyUnderline))
//                UIBarButtonItem(title: "Num List", style: .plain, target: self, action: #selector(applyNumberedList))
//                UIBarButtonItem(title: "Test", style: .plain, target: self, action: #selector(testingElements))
            ]
            toolbar.sizeToFit()
            return toolbar
        }
}
