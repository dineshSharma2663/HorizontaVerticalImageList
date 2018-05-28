//
//  APIManager.swift
//  DeltaTask
//
//  Created by Dinesh Kumar on 27/05/18.
//  Copyright © 2018 Dinesh Kumar. All rights reserved.
//

import UIKit


public enum API_Method:String{
    case get = "GET"
    case put = "PUT"
    case post = "POST"
}

public struct APIServices{
    static let getImagesList = "api/assignment"
}

public typealias API_SUCCESS = (_ response: Any) -> Void
public typealias API_ERROR = (_ error: Error?) -> Void



final class APIManager {
    
    static let shared = APIManager()

    static let API_RESPONSE_STRING = "DELTA TASK API-RESPONSE ->>> "
    private let baseUrl = "https://dev.deltaapp.in/"
    private let session = URLSession.shared
    private init() {   }

    public func isInternetConnection()->Bool{
        return  StatusBarErrorMessage.sharedInstance.reachability?.isReachable ?? false

    }
    
    /// Method to Hit Server call with provided details path & method, params
    ///
    /// - Parameters:
    ///   - apiPath: <#apiPath description#>
    ///   - httpMethod: <#httpMethod description#>
    ///   - params: <#params description#>
    ///   - completionSuccess: <#completionSuccess description#>
    ///   - failure: <#failure description#>
    open func proceedRequestWith(apiPath:String,httpMethod:API_Method,params:AnyObject? = nil,completionSuccess : @escaping API_SUCCESS, failure:@escaping API_ERROR){
        
        let urlString = self.baseUrl + apiPath
        let request = getRequestWithDetails(apiPath: apiPath, httpMethod: httpMethod, params: params)
        guard let _request = request else {
            print("Invalid API URLRequest")
            return
        }
        
        let dataTask = session.dataTask(with: _request) {data,response,error in
            if (error != nil) {
                print(error?.localizedDescription ?? "")
                NSLog(APIManager.API_RESPONSE_STRING + "%@%@",  urlString + "\nURLSESSION TASK ERROR ->>> ",(error?.localizedDescription ?? ""))
                DispatchQueue.main.async {
                failure(error)
                }
                return
            } else {
                guard let _data = data else {
                    print("Data is empty")
                    return
                }
                do{
                    let json = (try JSONSerialization.jsonObject(with: _data, options: .allowFragments))
                    DispatchQueue.main.async {
                        completionSuccess(json)
                    }
                    
                } catch let error {
                    NSLog(APIManager.API_RESPONSE_STRING + "%@",  urlString + "\nJSON PARSE ERROR ->>> " + error.localizedDescription)
                    DispatchQueue.main.async {
                    failure(error)
                    }
               }
            }
        }
        dataTask.resume()
    }
    
    
    /// <#Description#>
    ///
    /// - Parameters:
    ///   - apiPath: <#apiPath description#>
    ///   - httpMethod: <#httpMethod description#>
    ///   - params: <#params description#>
    /// - Returns: <#return value description#>
    private func getRequestWithDetails(apiPath:String,httpMethod:API_Method,params:AnyObject? = nil)->URLRequest?{
        let urlString = self.baseUrl + apiPath
        guard let apiUrl = URL(string: urlString) else {
            print("Invalid API URL.")
            return nil}
        let request = NSMutableURLRequest(url: apiUrl)
        request.httpMethod = httpMethod.rawValue
        return request as URLRequest
    }
        
}
