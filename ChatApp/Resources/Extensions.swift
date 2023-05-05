//
//  Extensions.swift
//  ChatApp
//
//  Created by 安達さくら on 2023/05/06.
//

// Helper extention for UI as coding UI is gonna get repetitive
import Foundation
import UIKit

extension UIView{
    
    public var width: CGFloat {
        return frame.size.width
    }

    public var height: CGFloat {
        return frame.size.height
    }

    public var top: CGFloat {
        return frame.origin.y
    }

    public var bottom: CGFloat {
        return frame.size.height + frame.origin.y
    }

    public var left: CGFloat {
        return frame.origin.x
    }

    public var right: CGFloat {
        return frame.size.width + frame.origin.x
    }
}
