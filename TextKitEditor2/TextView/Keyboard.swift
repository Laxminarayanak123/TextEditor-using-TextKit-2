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
        stackView.spacing = 40
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)
        
        // Pin the stack view to the scroll view
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
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
            ("list.number", #selector(toggleNumberList)),
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
            stackView.addArrangedSubview(button)
            
            if iconName == "bold" {
                boldButton = button
            }
            
            if iconName == "italic" {
                italicButton = button
            }
            
            if iconName == "underline" {
                underlineButton = button
            }
            
            if iconName == "strikethrough" {
                strikeThroughButton = button
            }
        }
        
        // Set container view height
        containerView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50)
        
        return containerView
    }
    
    func updateButton(for button: UIButton, isEnabled: Bool, iconName: String) {
        let activeColor = UIColor.systemGreen
        let inactiveColor = UIColor.label
        
        // Update the button's image
        let configuration = UIImage.SymbolConfiguration(pointSize: 21, weight: .semibold)
        let newImage = UIImage(systemName: iconName, withConfiguration: configuration)?
            .withTintColor(isEnabled ? activeColor : inactiveColor, renderingMode: .alwaysOriginal)
        
        // Resize the button
        button.bounds = CGRect(x: 0, y: 0, width: 20, height: 20)
        button.setImage(newImage, for: .normal)
        
        // Set the background color
//        button.backgroundColor = isEnabled ? activeColor : inactiveColor
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
    
}
    

extension TextView{
    //wrappers
    
    @objc func toggleCheckBoxWrapper(){
        let range : NSRange = paragraphRange
        toggleSelected(range: range)
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
