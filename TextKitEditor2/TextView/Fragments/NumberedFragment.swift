//
//  NumberedFragment.swift
//  TextKitEditor2
//
//  Created by Laxmi Narayana Koyyana on 19/12/24.
//
import UIKit

class NumberedListTextLayoutFragment : NSTextLayoutFragment {
    private let numberPadding: CGFloat = 3
     var number: Int = 0
    
    init(textElement: NSTextElement, range: NSTextRange, number: Int) {
            self.number = number
            super.init(textElement: textElement, range: range)
        }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var renderingSurfaceBounds: CGRect {
        let bounds = super.renderingSurfaceBounds
        // Increased width to accommodate larger numbers
        let rect = CGRect(origin: .init(x: -48, y: bounds.origin.y),
                          size: .init(width: bounds.size.width + 48, height: bounds.size.height))
        return rect
    }
    
    override func draw(at point: CGPoint, in context: CGContext) {
        
        let font = UIFont.systemFont(ofSize: 24)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor.label,
        ]
        
        let numberString = "\(number)."
        let numberSize = numberString.size(withAttributes: attributes)
        
        // Create a rect that's large enough for the text
        let numberRect = CGRect(
            x: renderingSurfaceBounds.origin.x,
            y: point.y + numberPadding,
            width: 48,
            height: numberSize.height
        )
        
//        context.saveGState()
//        context.setFillColor(UIColor.blue.cgColor)
//        context.fill(numberRect)
//        context.restoreGState()
        
        // Draw the number
        context.saveGState()
        numberString.draw(
            in: numberRect,
            withAttributes: attributes
        )
        context.restoreGState()
        
        super.draw(at: point, in: context)
    }
}
