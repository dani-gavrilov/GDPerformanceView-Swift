//
// Copyright © 2017 Gavrilov Daniil
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

import UIKit

internal class GDMarginLabel: UILabel {
    
    // MARK: Private Properties
    
    private var edgeInsets: UIEdgeInsets = UIEdgeInsetsMake(0.0, 5.0, 0.0, 5.0)
    
    // MARK: Properties Overriders
    
    override internal var intrinsicContentSize: CGSize {
        get {
            var size = super.intrinsicContentSize
            size.width += self.edgeInsets.left + self.edgeInsets.right
            size.height += self.edgeInsets.top + self.edgeInsets.bottom
            return size
        }
    }
    
    // MARK: Init Methods & Superclass Overriders
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: UIEdgeInsetsInsetRect(rect, self.edgeInsets))
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var sizeThatFits = super.sizeThatFits(size)
        sizeThatFits.width += self.edgeInsets.left + self.edgeInsets.right
        sizeThatFits.height += self.edgeInsets.top + self.edgeInsets.bottom
        return sizeThatFits
    }
    
}
