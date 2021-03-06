//
//  AutogrowingTextView.swift
//  Proton
//
//  Created by Rajdeep Kwatra on 31/12/19.
//  Copyright © 2019 Rajdeep Kwatra. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation
import UIKit

class AutogrowingTextView: UITextView {
    private let dimensionsCalculatingTextView = UITextView()

    var maxHeight: CGFloat = 0 {
        didSet {
            guard maxHeight > 0 else {
                maxHeightConstraint.isActive = false
                return
            }

            maxHeightConstraint.constant = maxHeight
            maxHeightConstraint.isActive = true
        }
    }

    weak var boundsObserver: BoundsObserving?
    var maxHeightConstraint: NSLayoutConstraint!

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        maxHeightConstraint = heightAnchor.constraint(lessThanOrEqualToConstant: frame.height)
        isScrollEnabled = false
        NSLayoutConstraint.activate([
            heightAnchor.constraint(greaterThanOrEqualToConstant: frame.height)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let bounds = self.bounds
        updateDimensionsCalculatingTextView()
        let fittingSize = dimensionsCalculatingTextView.sizeThatFits(CGSize(width: frame.width, height: .greatestFiniteMagnitude))
        isScrollEnabled = (fittingSize.height > bounds.height) || (maxHeight > 0 && maxHeight < fittingSize.height)
    }

    override open func sizeThatFits(_ size: CGSize) -> CGSize {
        updateDimensionsCalculatingTextView()
        var fittingSize = dimensionsCalculatingTextView.sizeThatFits(size)
        if maxHeight > 0 {
            fittingSize.height = min(maxHeight, fittingSize.height)
        }
        return fittingSize
    }

    override var bounds: CGRect {
        didSet {
            guard oldValue.height != bounds.height else { return }
            boundsObserver?.didChangeBounds(bounds)
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.becomeFirstResponder()
    }

    private func updateDimensionsCalculatingTextView() {
        dimensionsCalculatingTextView.font = font
        dimensionsCalculatingTextView.attributedText = attributedText
        dimensionsCalculatingTextView.textContainerInset = textContainerInset
    }
}
