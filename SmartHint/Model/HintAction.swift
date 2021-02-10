//
//  Action.swift
//  YMMHintManager
//
//  Created by Gautier Billard on 03/02/2021.
//

import Foundation

public class HintAction {
    var identifier: String = UUID().uuidString
    var title: String?
    var handler: (()->Void)?
    
    public init(title: String? = nil, handler: (() -> Void)? = nil) {
        self.title = title
        self.handler = handler
    }
}
