//
//  CustomLayoutManager.swift
//  TextKitEditor2
//
//  Created by Laxmi Narayana Koyyana on 04/12/24.
//
import UIKit


class CheckboxTextLayoutFragment: NSTextLayoutFragment {
    let checkboxSize: CGSize = CGSize(width: 24, height: 24)
    let checkBoxStrokeWidth : CGFloat = 2
    var isChecked: Bool = false
    
    
    // increasing renderigSurfaceBounds bounds to draw checkbox
    override var renderingSurfaceBounds: CGRect{
        let bounds = super.renderingSurfaceBounds
        
        let rect = CGRect(origin: .init(x: -54, y: bounds.origin.y), size: .init(width: bounds.size.width + 54, height: bounds.size.height))
        
        return rect
    }
    
    override func draw(at point: CGPoint, in context: CGContext) {
        
        super.draw(at: point, in: context)

    }
}


