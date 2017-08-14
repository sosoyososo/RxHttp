//
//  RAError.swift
//  RxAlamofire
//
//  Created by karsa on 2017/8/14.
//  Copyright © 2017年 karsa. All rights reserved.
//

import Foundation

open class RAError : Error {
    public var domain : String = "RAHttp"
    public var code : Int = -1
    public var message : String = "Unknown Error"
    public var userInfo : [String:Any]? = nil
    
    public init(_ domain : String? = nil
        , code : Int? = nil
        , message : String? = nil
        , userInfo : [String:Any]? = nil) {
        
        if let domain = domain {
            self.domain = domain
        }
        if let code = code {
            self.code = code
        }
        if let message = message {
            self.message = message
        }
        if let userInfo = userInfo {
            self.userInfo = userInfo
        }
    }
}
