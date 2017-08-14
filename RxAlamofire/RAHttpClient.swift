//
//  RAHttpJsonClient.swift
//  RxAlamofire
//
//  Created by karsa on 2017/8/14.
//  Copyright © 2017年 karsa. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire
import ObjectMapper

open class RAHttpJsonClient {
    public static var globalParameter : [String:Any]? = nil
    
    public class func ObservableJsonRequest(_ url: URLConvertible
        , method: Alamofire.HTTPMethod = .get
        , parameters: Parameters? = nil
        , encoding: ParameterEncoding = JSONEncoding.default
        , headers: HTTPHeaders? = nil
        , requestChecker : @escaping (Alamofire.DataRequest)->RAError? = {_ in return nil}
        , requestConfig : @escaping (Alamofire.DataRequest)->() = {_ in}) -> Observable<Any> {
        
        let observable = Observable<Any>.create { (observer) -> Disposable in
            var relParameters : [String:Any] = [:]
            if let p = RAHttpJsonClient.globalParameter {
                _=p.map({ (k, v) in
                    relParameters[k] = v
                })
                _=parameters?.map({ (k, v) in
                    relParameters[k] = v
                })
            }
            let request = Alamofire.request(url
                , method: method
                , parameters: parameters
                , encoding: encoding
                , headers: headers)
            if let err = requestChecker(request) {
                observer.onError(err)
            } else {
                requestConfig(request)
                request.responseJSON(completionHandler: { (resp) in
                    if let err = resp.error {
                        observer.onError(err)
                    } else {
                        if let value = resp.value {
                            observer.onNext(value)
                            observer.onCompleted()
                        } else {
                            observer.onNext(RAError.init(message: "Data is Empty"))
                        }
                    }
                })
            }
            return Disposables.create()
        }
        return observable
    }
    
    public class func ObservableJsonObjectRequest<M : Mappable>(_ url: URLConvertible
        , method: Alamofire.HTTPMethod = .get
        , parameters: Parameters? = nil
        , encoding: ParameterEncoding = JSONEncoding.default
        , headers: HTTPHeaders? = nil
        , requestChecker : @escaping (Alamofire.DataRequest)->RAError? = {_ in return nil}
        , requestConfig : @escaping (Alamofire.DataRequest)->() = {_ in}) -> Observable<[M]> {
        
        let observable = Observable<[M]>.create { (observer) -> Disposable in
            _=RAHttpJsonClient.ObservableJsonRequest(url
                , method: method
                , parameters: parameters
                , encoding: encoding
                , headers: headers
                , requestChecker: requestChecker
                , requestConfig: requestConfig).subscribe(onNext: { (json) in
                if let arr = json as? [[String:Any]] {
                    observer.onNext(Array<M>.init(JSONArray: arr))
                    observer.onCompleted()
                } else if let json = json as? [String:Any] {
                    if let m = M(JSON: json) {
                        observer.onNext([m])
                        observer.onCompleted()
                    } else {
                        observer.onError(RAError.init("Json", message: "Map to Object Failed"))
                    }
                }
            }, onError: { err in
                observer.onError(err)
            }, onCompleted: {
                observer.onCompleted()
            })
            
            return Disposables.create()
        }
        return observable
    }
}
