//
//  TextView_ViewPort.swift
//  TextKitEditor2
//
//  Created by Laxmi Narayana Koyyana on 22/11/25.
//

import UIKit

extension TextView : NSTextViewportLayoutControllerDelegate {
    
    func viewportBounds(for textViewportLayoutController: NSTextViewportLayoutController) -> CGRect {
        
        let offset = self.frame.height / 2
        
        let rect : CGRect = .init(x: 0, y: contentOffset.y - offset, width: bounds.size.width, height: 2 * bounds.size.height)
        
        return rect
    }
    
    func textViewportLayoutControllerWillLayout(_ controller: NSTextViewportLayoutController) {
        
        let offset = self.frame.height / 2
        
        let visiblerect : CGRect = .init(x: 0, y: contentOffset.y - offset, width: frame.width, height: 2 * frame.height)
        
        renderingViews_Container.subviews.forEach {
            if !visiblerect.contains($0.frame) {
                $0.removeFromSuperview()
            }
        }
        
        checkboxViews_Container.subviews.forEach {
            if !visiblerect.contains($0.frame) {
                $0.removeFromSuperview()
            }
        }
        CATransaction.begin()
    }
    
    
    func textViewportLayoutController(_ textViewportLayoutController: NSTextViewportLayoutController,
                                      configureRenderingSurfaceFor textLayoutFragment: NSTextLayoutFragment) {
        let (fragmentView, didCreate) = findOrCreateTextRenderingView(textLayoutFragment)
        if !didCreate {
            let oldFrame = fragmentView.frame
            let oldBounds = fragmentView.bounds
            fragmentView.updateGeometry()
            if oldBounds != fragmentView.bounds {
                fragmentView.setNeedsDisplay()
            }
            if oldFrame.origin != fragmentView.frame.origin {
//                animate(fragmentView, from: oldFrame.origin, to: fragmentView.frame.origin)
            }
        }
        
        renderingViews_Container.addSubview(fragmentView)
        
        if let textLayoutFragment = textLayoutFragment as? CheckboxTextLayoutFragment {

            let (checkboxView, _) = findOrCreateCheckboxView(for: textLayoutFragment)
            
            let fragmentFrame = textLayoutFragment.layoutFragmentFrame
            
            
            
            
            checkboxView.frame = getCheckBoxFrameFromGivenFrame(fragmentFrame: fragmentFrame)
            checkboxViews_Container.addSubview(checkboxView)

            
            // cleanup of checkbox views
            oldCheckBoxFragmentMap.removeValue(forKey: textLayoutFragment)
            
            newCheckBoxFragmentMap[textLayoutFragment] = checkboxView
            
        }
        
        // cleanup of text rendering views
        oldRenderingViewMap.removeValue(forKey: textLayoutFragment)

        newRenderingViewMap[textLayoutFragment] = fragmentView

    }
    
    func textViewportLayoutControllerDidLayout(_ controller: NSTextViewportLayoutController) {
        
        // cleanup of views
        for item in oldCheckBoxFragmentMap{
            item.value.removeFromSuperview()
        }
        
        for item in oldRenderingViewMap{
            item.value.removeFromSuperview()
        }
        
        oldCheckBoxFragmentMap = newCheckBoxFragmentMap
        oldRenderingViewMap = newRenderingViewMap
        newCheckBoxFragmentMap.removeAll()
        newRenderingViewMap.removeAll()
        
        CATransaction.commit()
    }
    
    func updateContentSizeIfNeeded() {
        
        let currentHeight = bounds.height
        var height: CGFloat = 0
        textLayoutManager!.enumerateTextLayoutFragments(from: textLayoutManager!.documentRange.endLocation,
                                                        options: [.reverse, .ensuresLayout]) { layoutFragment in
            height = layoutFragment.layoutFragmentFrame.maxY
            return false // stop
        }
        height = max(height, contentSize.height)
        if abs(currentHeight - height) > 1e-10 {
            let contentSize = CGSize(width: self.bounds.width, height: height)
            self.contentSize = contentSize
        }
    }
    
    func findOrCreateTextRenderingView(_ textLayoutFragment: NSTextLayoutFragment) -> (TextRenderingView, Bool) {
        if let view = fragmentRenderingViewMap.object(forKey: textLayoutFragment) {
            return (view, false)
        } else {
            let view = TextRenderingView(layoutFragment: textLayoutFragment, padding: padding)
            fragmentRenderingViewMap.setObject(view, forKey: textLayoutFragment)
            view.isUserInteractionEnabled = false
            return (view, true)
        }
    }
    
    
    
    func animate(_ view: UIView, from source: CGPoint, to destination: CGPoint) {
//        let animation = CABasicAnimation(keyPath: "position")
//        animation.fromValue = source
//        animation.toValue = destination
//        animation.duration = 0.6
//        view.layer.add(animation, forKey: nil)
        view.transform = .init(translationX: 0, y: source.y)
        
        UIView.animate(withDuration: 0.8) {
            view.transform = .init(translationX: 0, y: destination.y)
        }
    }
    
    func findOrCreateCheckboxView(for textLayoutFragment: NSTextLayoutFragment) -> (UIView, Bool) {
        if let view = fragmentCheckBoxViewMap.object(forKey: textLayoutFragment) {
            return (view, false)
        } else {
            // Customize this view however you want
            let v = CheckBoxView()
//            v.backgroundColor = .systemYellow // just to see it
            v.textLayoutFragment = textLayoutFragment
            v.textView = self
            
            if let fragment = textLayoutFragment as? CheckboxTextLayoutFragment{

                if fragment.isChecked{
                    v.check()
                }
                else{
                    v.unCheck()
                }
                
            }
            
            // You can also plug in a custom checkbox view here.
            fragmentCheckBoxViewMap.setObject(v, forKey: textLayoutFragment)
            return (v, true)
        }
    }
    
//    override func caretRect(for position: UITextPosition) -> CGRect {
//        let superRect = super.caretRect(for: position)
//        let rect = CGRect(origin: superRect.origin, size: .init(width: 50, height: 2))
//        
//        return isDraggingCheckbox ? rect : superRect
//    }
    
    func getCheckBoxFrameFromGivenFrame(fragmentFrame : CGRect) -> CGRect{
                
        let viewWidth: CGFloat = 32
        let viewX: CGFloat = fragmentFrame.minX - viewWidth
        let padding = 17.0
        let viewFrame = CGRect(
            x: viewX - padding,
            y: fragmentFrame.minY + 10,
            width: viewWidth,
            height: viewWidth
        )
        
        return viewFrame
    }
}
