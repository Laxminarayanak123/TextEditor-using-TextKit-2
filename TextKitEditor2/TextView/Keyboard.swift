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
    }
    
    @objc func keyboardWillShowNotification(_ notification : Notification) {
        
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        
        contentInset.bottom = (keyboardScreenEndFrame.height - safeAreaInsets.bottom)
        scrollRangeToVisible(selectedRange)
    }
    
    @objc func keyboardWillHideNotification(_ : Notification) {
        contentInset.bottom = .zero
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
        updateIndentButton(for: leftIndentButton!, isEnabled: leftIndentEnabled, iconName: "text.alignleft")
    }
    
    func updaterightIndentButton() {
        updateIndentButton(for: rightIndentButton!, isEnabled: rightIndentEnabled, iconName: "text.alignright")
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

    func updateStrikeButton() {
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
        toggleSelected(range: range)
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
