//
//  CustomLayoutManager.swift
//  TextKitEditor2
//
//  Created by Laxmi Narayana Koyyana on 04/12/24.
//
import UIKit


class CheckboxTextLayoutFragment: NSTextLayoutFragment {
    private let checkboxSize: CGSize = CGSize(width: 20, height: 20)
    private let checkboxPadding: CGFloat = 5
    
    override var renderingSurfaceBounds: CGRect{
        let bounds = super.renderingSurfaceBounds
        
        let rect = CGRect(origin: .init(x: -42, y: bounds.origin.y), size: .init(width: bounds.size.width + 42, height: bounds.size.height))
        
        return rect
    }
    
    override func draw(at point: CGPoint, in context: CGContext) {
        
//        context.saveGState()
//        context.setFillColor(UIColor.blue.cgColor)
//        context.fill(renderingSurfaceBounds)
//        context.restoreGState()

        let firstLineFragment = self.textLineFragments.first!
        
        // Draw checkbox
        let checkboxRect = CGRect(
            x: renderingSurfaceBounds.origin.x,
            y: point.y + (checkboxSize.height)/2,
            width: checkboxSize.width,
            height: checkboxSize.height
        )

//        let checkboxImage = UIImage(systemName: "square") // Use "checkmark.square" for checked
        
        context.saveGState()

//        context.setFillColor(UIColor.green.cgColor)
//        let fragmentFrame = CGRect(origin: point, size: self.layoutFragmentFrame.size)
//        context.fill(fragmentFrame)
        
        context.setFillColor(UIColor.red.cgColor)
        context.fill(checkboxRect)
        
        context.restoreGState()
        
//        checkboxImage?.draw(in: checkboxRect)

        
        super.draw(at: point, in: context)

        

        // Offset the rest of the text to account for checkbox
//        let textDrawingPoint = CGPoint(x: point.x + checkboxSize.width + checkboxPadding, y: point.y)
//        context.saveGState()
//        context.translateBy(x: textDrawingPoint.x, y: textDrawingPoint.y)
//        super.draw(at: .zero, in: context)
//        context.restoreGState()
    }
}


