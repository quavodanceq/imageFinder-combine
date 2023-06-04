//
//  UITextField + Extension.swift
//  imageFinder-combine
//
//  Created by Куат Оралбеков on 03.06.2023.
//

import Foundation
import UIKit
import Combine

extension UITextField {
    
     var textPublisher: AnyPublisher<String?, Never> {
            NotificationCenter.default.publisher(
                for: UITextField.textDidChangeNotification,
                object: self
            )
            .compactMap { ($0.object as? UITextField)?.text }
            .debounce(for: .seconds(1), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
        }
    
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
    
    
}
