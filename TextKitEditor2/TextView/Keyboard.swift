//
//  Keyboard.swift
//  TextKitEditor2
//
//  Created by Laxmi Narayana Koyyana on 05/12/24.
//
import UIKit

extension TextView{
    func setUpNotifications() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(
            self,
            selector: #selector(keyboardWillShowNotification),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        notificationCenter.addObserver(
            self,
            selector: #selector(keyboardWillHideNotification),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
        notificationCenter.addObserver(self, selector: #selector(showKeyboard), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    @objc func showKeyboard() {
        // Ensure the keyboard is brought back for the desired text field or text view
        self.becomeFirstResponder() // Replace `textView` with your actual text input control
    }
    
    @objc func keyboardWillShowNotification(_ notification : Notification) {
        
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        
        contentInset.bottom = (keyboardScreenEndFrame.height - safeAreaInsets.bottom) + 50
        scrollRangeToVisible(selectedRange)
        
    }
    
    @objc func keyboardWillHideNotification(_ : Notification) {
        contentInset.bottom = 400
    }
    
    func createToolbar() -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .systemGray5
        
        // Create a scroll view for horizontal scrolling
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(scrollView)
        
        // Pin the scroll view to the container view
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: containerView.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        // Create a stack view to hold the toolbar buttons
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 5
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)
        
        // Pin the stack view to the scroll view
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 5),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -10),
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        ])
        
        let symbolColor = UIColor.label
        let configuration = UIImage.SymbolConfiguration(pointSize: 21, weight: .semibold)
        
        // Add buttons to the stack view
        let buttons = [
            ("arrow.uturn.backward", #selector(undoAction)),
            ("arrow.uturn.forward", #selector(redoAction)),
            
            ("bold", #selector(setBold)),
            ("italic", #selector(setItalic)),
            ("underline", #selector(setUnderline)),
            ("strikethrough", #selector(setStrikeThrough)),
            ("checkmark.circle", #selector(toggleCheckBoxWrapper)),
            ("list.number", #selector(toggleNumberedListWrapper)),
            ("text.alignleft", #selector(leftIndentWrapper)),
            ("text.alignright", #selector(rightIndentWrapper)),
            //                    ("hand.tap", #selector(toggleTap)),
        ]
        
        for (iconName, action) in buttons {
            let button = UIButton(type: .system)
            button.setImage(
                UIImage(systemName: iconName, withConfiguration: configuration)?
                    .withTintColor(symbolColor, renderingMode: .alwaysOriginal),
                for: .normal
            )
            button.addTarget(self, action: action, for: .touchUpInside)
            
            // Set the button's background to a square shape
            button.backgroundColor = .systemGray5 // Set your desired background color
            button.layer.cornerRadius = 3 // Adjust for square corners (set to a smaller value for rounded squares)
            button.clipsToBounds = true

            // Set a fixed size for the button to ensure square dimensions
            button.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                button.widthAnchor.constraint(equalToConstant: 70),
                button.heightAnchor.constraint(equalToConstant: 20)
            ])
            
            stackView.addArrangedSubview(button)
            
            // Reference specific buttons for additional functionality
            switch iconName{
                case  "bold" : boldButton = button
                case  "italic" : italicButton = button
                case  "underline" : underlineButton = button
                case  "strikethrough" : strikeThroughButton = button
                case  "checkmark.circle" : checkListButton = button
                case  "list.number" : numberedListButton = button
                case "text.alignright" : rightIndentButton = button
                case "text.alignleft" : leftIndentButton = button
                default:
                    break
            }
        }
        
        // Set container view height
        containerView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50)
        
        return containerView
    }
    
    
    func updateButton(for button: UIButton, isEnabled: Bool, iconName: String) {
        let activeColor = UIColor.white
        let inactiveColor = UIColor.label
        let activeBackgroundColor = UIColor.systemGray
        let inactiveBackgroundColor = UIColor.systemGray5
        
        // Update the button's image with the appropriate tint color
        let configuration = UIImage.SymbolConfiguration(pointSize: 21, weight: .semibold)
        if let newImage = UIImage(systemName: iconName, withConfiguration: configuration)?
            .withTintColor(isEnabled ? activeColor : inactiveColor, renderingMode: .alwaysOriginal) {
            button.setImage(newImage, for: .normal)
        }
        
        // Update the button's background color
        button.backgroundColor = isEnabled ? activeBackgroundColor : inactiveBackgroundColor
        
        button.layer.cornerRadius = 3
        button.clipsToBounds = true
    }
    
    func updateIndentButton(for button: UIButton, isEnabled: Bool, iconName: String) {
        
        let configuration = UIImage.SymbolConfiguration(pointSize: 21, weight: .semibold)
        if let newImage = UIImage(systemName: iconName, withConfiguration: configuration)?
            .withTintColor(.label, renderingMode: .alwaysOriginal) {
            button.setImage(newImage, for: .normal)
        }
        button.alpha =  isEnabled ? 1.0 : 0.2
    }
    
    func updateLeftIndentButton() {
        updateIndentButton(for: leftIndentButton!, isEnabled: isLeftIndentEnabled, iconName: "text.alignleft")
    }
    
    func updaterightIndentButton() {
        updateIndentButton(for: rightIndentButton!, isEnabled: isRightIndentEnabled, iconName: "text.alignright")
    }

    func updateBoldButton() {
        updateButton(for: boldButton!, isEnabled: isBoldEnabled, iconName: "bold")
    }

    func updateItalicButton() {
        updateButton(for: italicButton!, isEnabled: isItalicEnabled, iconName: "italic")
    }

    func updateUnderlineButton() {
        updateButton(for: underlineButton!, isEnabled: isUnderlineEnabled, iconName: "underline")
    }

    func updateStrikeThroughButton() {
        updateButton(for: strikeThroughButton!, isEnabled: isStrikeThroughEnabled, iconName: "strikethrough")
    }
    
    func updateCheckListButton(){
        updateButton(for: checkListButton!, isEnabled: isCheckListEnabled, iconName: "checkmark.circle")
    }
    
    func updateNumberedListButton(){
        updateButton(for: numberedListButton!, isEnabled: isNumberedListEnabled, iconName: "list.number")
    }
    
}
    

extension TextView{
    //wrappers
    
    @objc func toggleCheckBoxWrapper(){
        let range : NSRange = paragraphRange
        toggleCheckBox(range: range)
    }
    
    @objc func toggleNumberedListWrapper(){
        let range : NSRange = paragraphRange
        toggleNumberList(range: range)
    }
    
    @objc func leftIndentWrapper(){
        let range : NSRange = paragraphRange
        leftIndent(range: range)
    }
    
    @objc func rightIndentWrapper(){
        let range : NSRange = paragraphRange
        rightIndent(range: range)
    }
}


extension TextView {
    
    // Updating toolbar button states
    func updateHighlighting(){
        isBoldEnabled = false
        isItalicEnabled = false
        isUnderlineEnabled = false
        isStrikeThroughEnabled = false
        isCheckListEnabled = false
        isNumberedListEnabled = false
        isLeftIndentEnabled = false
        isRightIndentEnabled = false
        
        if selectedRange.length > 0 {
            
            isCheckListEnabled = containsListType(range: selectedRange, paragraphType: .checkList, paragraphRanges: nil)
            isNumberedListEnabled = containsListType(range: selectedRange, paragraphType: .NumberedList, paragraphRanges: nil)
            isLeftIndentEnabled = canIndent(range: selectedRange, left: true, right: false)
            isRightIndentEnabled = canIndent(range: selectedRange, left: false, right: true)
            
            textStorage.enumerateAttributes(in: selectedRange, options: []) { attributes, range, _ in
                if let font = attributes[.font] as? UIFont {
                    let traits = font.fontDescriptor.symbolicTraits
                    if traits.contains(.traitBold) {
                        isBoldEnabled = true
                    }
                    if traits.contains(.traitItalic) {
                        isItalicEnabled = true
                    }
                }
                
                if let underlineStyle = attributes[.underlineStyle] as? Int, underlineStyle != 0 {
                    isUnderlineEnabled = true
                }
                
                if let strikeStyle = attributes[.strikethroughStyle] as? Int, strikeStyle != 0 {
                    isStrikeThroughEnabled = true
                }
                
                // Exit early if all styles are enabled
                if isBoldEnabled && isItalicEnabled && isUnderlineEnabled && isStrikeThroughEnabled {
                    return
                }
            }
        } else {
            guard let font = typingAttributes[.font] as? UIFont else {
                isBoldEnabled = false
                isItalicEnabled = false
                isUnderlineEnabled = false
                isStrikeThroughEnabled = false
                return
            }
            isLeftIndentEnabled = false
            isRightIndentEnabled = true
            
            isBoldEnabled = font.fontDescriptor.symbolicTraits.contains(.traitBold)
            isItalicEnabled = font.fontDescriptor.symbolicTraits.contains(.traitItalic)
            
            if let underlineStyle = typingAttributes[.underlineStyle] as? Int {
                isUnderlineEnabled = underlineStyle != 0
            } else {
                isUnderlineEnabled = false
            }
            
            if let strike = typingAttributes[.strikethroughStyle] as? Int {
                isStrikeThroughEnabled = strike != 0
            } else {
                isStrikeThroughEnabled = false
            }
            
            if selectedRange.location < textStorage.length {
                var minLevel = 0
                if let listType = textStorage.attribute(.listType, at: selectedRange.location, effectiveRange: nil){
                    minLevel = 1
                    if let _ = listType as? Int{
                        isNumberedListEnabled = true
                        isCheckListEnabled = false
                    }
                    else{
                        isCheckListEnabled = true
                        isNumberedListEnabled = false
                    }
                }
                else{
                    isCheckListEnabled = false
                    isNumberedListEnabled = false
                }
                
                if let indent = textStorage.attribute(.indentLevel, at: selectedRange.location, effectiveRange: nil) as? Int {
                    if indent > minLevel {
                        isLeftIndentEnabled = true
                    } else {
                        isLeftIndentEnabled = false
                    }
                    
                    if indent < 4 {
                        isRightIndentEnabled = true
                    } else {
                        isRightIndentEnabled = false
                    }
                }
            }
        }
    }
}
