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
    
    func textViewDidChangeSelection(_ textView: UITextView) {
//        _ = NSTextRange(selectedRange, contentManager: textLayoutManager!.textContentManager!)
//        print("selected Text", self.selectedRange, nstextrange?.location,nstextrange?.endLocation)
//        textLayoutManager?.enumerateTextLayoutFragments(from: nstextrange?.location, using: { fragment in
//            
//            print("fragment", fragment)
//            return true
//        })
        
    }
    
    func createToolbar() -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .white
        
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
        stackView.spacing = 50
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
        let symbolColor = UIColor.black
        let configuration = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
        
        // Add buttons to the stack view
        let buttons = [
            ("arrow.uturn.backward", #selector(undoAction)),
            ("arrow.uturn.forward", #selector(redoAction)),
            ("checkmark.circle", #selector(toggleSelected)),
            ("list.number", #selector(toggleNumberList)),
            ("text.alignleft", #selector(leftIndent)),
            ("text.alignright", #selector(rightIndent)),
                                ("hand.tap", #selector(toggleTap)),
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
        }
        
        // Set container view height
        containerView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50)
        
        return containerView
    }
    
}
