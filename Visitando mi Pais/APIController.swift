//
//  APIController.swift
//  Visitando mi Pais
//
//  Created by Alvaro De la Cruz Lockhart on 3/12/15.
//  Copyright (c) 2015 Alvaro De la Cruz Lockhart. All rights reserved.
//

import Foundation

protocol APIControllerProtocol{
    func didReceiveResponse(result: AnyObject)
}

class APIController{
    
    var delegate: APIControllerProtocol
    var url: NSString
    
    init(url: NSString, delegate: APIControllerProtocol){
        self.delegate = delegate
        self.url = url
    }
    
    
    func connect(){
        let url = NSURL(string: self.url)
        let session = NSURLSession.sharedSession()
        let dataTask = session.dataTaskWithURL(url!, completionHandler: {(data:NSData!, response: NSURLResponse!, error:NSError!) -> Void in
            // Making request
            print("Peticion realizada")
            if(error != nil){
                println(error.localizedDescription)
            }
            var err: NSError?
            var jsonResult: AnyObject? =  NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &err)
            if(err != nil){
                println("JSON Error \(err!.localizedDescription)")
            }else{
                self.delegate.didReceiveResponse(jsonResult!)
            }
        })
        dataTask.resume()
    }
    
}