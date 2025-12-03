//
//  Checklist_AutoSort.swift
//  TextKitEditor2
//
//  Created by Laxmi Narayana Koyyana on 02/12/25.
//

import UIKit

extension TextView{
    
    struct checkboxItem{
        let range : NSRange
        let state : Bool
    }
    
    func AutoSort(sourceRange : NSRange ){
        
        getContigiousCheckboxRanges(sourceRange: sourceRange)
        
        // continue the process if there are any checked checkboxes
        
        if checkedCheckboxes.isEmpty{
            
            toggleCheckBoxState(paragraphRange: sourceRange)
            
            // cleanup
            allcheckboxes.removeAll()
            checkedCheckboxes.removeAll()
            uncheckedCheckboxes.removeAll()
            
            return
        }
        
        StartAutoSortAnimation()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4){ [weak self] in
            
            guard let self = self else { return }
            
            modifyTextStorageWhenAutoSort(sourceRange : sourceRange)
            
            
            // cleanup
            allcheckboxes.removeAll()
            checkedCheckboxes.removeAll()
            uncheckedCheckboxes.removeAll()
        }
    }
    
    func getContigiousCheckboxRanges(sourceRange : NSRange){
        
        
        // up
        var leftMost = sourceRange.location
        
        var prevParagraphLocation = leftMost - 1
        
        while prevParagraphLocation >= 0{
            
            let prevParagraphRange = textStorage.mutableString.paragraphRange(for: NSRange(location: prevParagraphLocation, length: 0))
            
            if isCheckList(range: prevParagraphRange){
                
                allcheckboxes.insert(checkboxItem(range: prevParagraphRange, state: getCheckListState(range: prevParagraphRange)), at: 0)
                
            }else{
                break
            }
            
            leftMost = prevParagraphRange.location
            
            prevParagraphLocation = leftMost - 1
            
        }
        
//        print(allcheckboxes)
        
        allcheckboxes.append(checkboxItem(range: sourceRange, state: !getCheckListState(range: sourceRange)))
        
        // down
        
        var rightMost = sourceRange.upperBound
        var nextParagraphLocation = rightMost
        
        while nextParagraphLocation < textStorage.length{
           
            let nextParagraphRange = textStorage.mutableString.paragraphRange(for: NSRange(location: nextParagraphLocation, length: 0))
            
            if isCheckList(range: nextParagraphRange){
                
                allcheckboxes.append(checkboxItem(range: nextParagraphRange, state: getCheckListState(range: nextParagraphRange)))
                
            }else{
                break
            }
            
            rightMost = nextParagraphRange.upperBound
            
            nextParagraphLocation = rightMost
            
        }
        
        print(allcheckboxes)
        
        
        // sort the checboxes into checked and unchecked
        
        for item in allcheckboxes{
            
            if item.state{
                checkedCheckboxes.append(item)
            }
            else{
                uncheckedCheckboxes.append(item)
            }
        }
        
        
        
        
        
       
    }
    
    
    func StartAutoSortAnimation(){
        
        guard let tlm = textLayoutManager, let tcm = textContentStorage ,let targetRange = NSTextRange(checkedCheckboxes[0].range, contentManager: tcm) else{ return }
        
        var targetPoint = 0.0
        
        if let fragment = tlm.textLayoutFragment(for: targetRange.location){
            targetPoint = fragment.layoutFragmentFrame.minY
        }
        
        // for uncheckedCheckBoxes
        for item in uncheckedCheckboxes{
            
            // only do animations after a top most checked guy
            if item.range.location < checkedCheckboxes[0].range.location{
                continue
            }
            
            if let textRange = NSTextRange(item.range, contentManager: tcm), let fragment = tlm.textLayoutFragment(for: textRange.location){
                
                if let view = fragmentRenderingViewMap.object(forKey: fragment), let checkboxView = fragmentCheckBoxViewMap.object(forKey: fragment){
                    UIView.animate(withDuration: 0.3) {
                        let rect = CGRect(origin: .init(x: view.frame.origin.x, y: targetPoint), size: view.frame.size)
                        view.frame = rect
                        
                        //                        view.transform = .init(translationX: 0, y: )
                        
                        let fragFrame = fragment.layoutFragmentFrame
                        let rect2 = CGRect(origin: .init(x: fragFrame.origin.x, y: targetPoint), size: fragFrame.size)
                        checkboxView.frame = self.getCheckBoxFrameFromGivenFrame(fragmentFrame: rect2)
                        
                    }
                }
                
                targetPoint = targetPoint + fragment.layoutFragmentFrame.height
            }
        }
        
        
        for item in checkedCheckboxes{
            if let textRange = NSTextRange(item.range, contentManager: tcm), let fragment = tlm.textLayoutFragment(for: textRange.location){
                
                if let view = fragmentRenderingViewMap.object(forKey: fragment), let checkboxView = fragmentCheckBoxViewMap.object(forKey: fragment){
                    UIView.animate(withDuration: 0.3) {
                        let rect = CGRect(origin: .init(x: view.frame.origin.x, y: targetPoint), size: view.frame.size)
                        view.frame = rect
                        
                        checkboxView.frame = self.getCheckBoxFrameFromGivenFrame(fragmentFrame: rect)
                        
                        let fragFrame = fragment.layoutFragmentFrame
                        let rect2 = CGRect(origin: .init(x: fragFrame.origin.x, y: targetPoint), size: fragFrame.size)
                        checkboxView.frame = self.getCheckBoxFrameFromGivenFrame(fragmentFrame: rect2)

                    }
                }
                
                targetPoint = targetPoint + fragment.layoutFragmentFrame.height
            }
        }
        
        
        
    }
    
    func modifyTextStorageWhenAutoSort(sourceRange : NSRange){
        
        guard let lastCheckBoxItem = allcheckboxes.last else{ return }
        
        var startingRange = checkedCheckboxes[0].range
        
        if sourceRange.location < startingRange.location{
            startingRange = sourceRange
        }
        
        let endingRange = lastCheckBoxItem.range
        
        let replaceRange = NSUnionRange(startingRange, endingRange)
        
        // create the actual string
        
        let mutableAttrString = NSMutableAttributedString()
        
        for item in uncheckedCheckboxes{
            
            
            if item.range.location < startingRange.location{
                continue
            }
            
            
            
            let tempString = NSMutableAttributedString()
           
            let attrString = textStorage.attributedSubstring(from: item.range)
            
            tempString.append(attrString)

            if !attrString.string.hasSuffix("\n"){
                tempString.append(NSAttributedString(string: "\n",attributes: tempString.attributes(at: 0, effectiveRange: nil)))
            }
            
            if item.range == sourceRange{
                
                let val = getCheckListState(range: sourceRange)
                
                tempString.addAttribute(.checkListState, value: !val, range: NSRange(location: 0, length: tempString.length - 1))
            }

            
            mutableAttrString.append(tempString)
            
        }
        
        for item in checkedCheckboxes{
            
            let tempString = NSMutableAttributedString()
           
            let attrString = textStorage.attributedSubstring(from: item.range)
            
            tempString.append(attrString)

            if !attrString.string.hasSuffix("\n"){
                tempString.append(NSAttributedString(string: "\n",attributes: tempString.attributes(at: 0, effectiveRange: nil)))
            }
            
            if item.range == sourceRange{
                
                let val = getCheckListState(range: sourceRange)
                
                tempString.addAttribute(.checkListState, value: !val, range: NSRange(location: 0, length: tempString.length - 1))
            }

            mutableAttrString.append(tempString)
            
        }
        
        let originalString = textStorage.attributedSubstring(from: replaceRange)
        
        undoManager?.beginUndoGrouping()
        
        textStorage.replaceCharacters(in: replaceRange, with: mutableAttrString)
        
        let newRange = NSRange(location: replaceRange.location, length: mutableAttrString.length)
        
        undoManager?.registerUndo(withTarget: self, handler: { target in
            self.handleUndo(range: newRange, oldText: originalString, newText: mutableAttrString)
        })
        
        undoManager?.endUndoGrouping()
        
        
    }
    
    func isCheckList(range : NSRange) -> Bool {
        
        if let listType = textStorage.attribute(.listType, at: range.location, effectiveRange: nil) as? String{
            if listType == paragraphType.checkList.rawValue{
                return true
            }
        }
        
        return false
    }
    
    func getCheckListState(range : NSRange) -> Bool {
        if let state = textStorage.attribute(.checkListState, at: range.location, effectiveRange: nil) as? Bool{
            return state
        }
        
        return false
    }
    
    func handleUndo(range: NSRange, oldText: NSAttributedString, newText: NSAttributedString){
        
        textStorage.replaceCharacters(in: range, with: oldText)

        selectedRange = NSRange(location: range.location, length: oldText.length)
        
        let newRange = NSRange(location: range.location, length: oldText.length)
        
        scrollRangeToVisible(selectedRange)

        undoManager?.registerUndo(withTarget: self) { target in
            target.handleRedo(range: NSMakeRange(range.location, oldText.length),
                                     oldText: oldText,
                                     newText: newText)
        }
        
    }
    
    func handleRedo(range: NSRange, oldText: NSAttributedString, newText: NSAttributedString){
        
        textStorage.replaceCharacters(in: range, with: newText)

        selectedRange = NSRange(location: range.location, length: newText.length)
        
        let newRange = NSRange(location: range.location, length: newText.length)
        
        scrollRangeToVisible(selectedRange)

        undoManager?.registerUndo(withTarget: self) { target in
        
            target.handleUndo(range: NSMakeRange(range.location, newText.length), oldText: oldText, newText: newText)
            
        }
        
        
    }
    
}
