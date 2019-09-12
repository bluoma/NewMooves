//
//  BindableTextField.swift
//  Mooveeze
//
//  Created by Bill on 9/9/19.
//  Copyright © 2019 Bill. All rights reserved.
//

import UIKit

class BindableTextField: UITextField {
    
    var textDidChange: ((String) -> ())?
    
    func bind(_ callback: @escaping (String) -> ()) {
        self.textDidChange = callback
        self.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    @objc func textFieldDidChange(_ textField :UITextField) {
        guard let foundText = textField.text else { return }
        self.textDidChange?(foundText)
    }
    
}
