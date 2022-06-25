//
//  Box.swift
//
//  Created by badi3 on 11/05/2021.
//

import Foundation

class Box<T>{
    typealias BoxListener = (T) -> Void
    var listener: BoxListener?
    var value: T{
        didSet{
            listener?(value)
        }
    }
    
    init(_ value: T){
        self.value = value
    }
    
    func bind(listener: BoxListener?){
        self.listener = listener
        listener?(value)
    }
}
