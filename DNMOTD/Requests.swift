//
//  GetMOTD.swift
//  DNMOTD
//
//  Created by ray on 31/05/2017.
//  Copyright © 2017 rayps. All rights reserved.
//

import Kanna
import SwiftyJSON


var currentID: Int = 0
var latestID: Int = 0


func getlatestID(completion: @escaping () -> Void) {
    
    let url = URL(string: "https://www.designernews.co")
    
    let task = URLSession.shared.dataTask(with: url!) {(data, response, error) in
        if let html = data, let doc = HTML(html: html, encoding: .utf8) {
            if let result = doc.css("#feed-motd-container").first {
                let id = result["data-id"]!
                DispatchQueue.main.async {
                    latestID = Int(id)!
                    completion()
                }
            }
        }
    }
    
    task.resume()
}


func getMOTD(byID id: Int, completion: @escaping (_ json: JSON) -> Void) {
    
    let url = URL(string: "https://api.designernews.co/api/v2/motds/\(id)")
    
    let task = URLSession.shared.dataTask(with: url!) {(data, response, error) in
        
        if let jsondata = data {
            DispatchQueue.main.async {
                completion(JSON(data: jsondata))
            }
        }
    }

    task.resume()
}


func getUser(byID id: Int, completion: @escaping (_ json: JSON) -> Void) {
    
    let url = URL(string: "https://api.designernews.co/api/v2/users/\(id)")
    
    let task = URLSession.shared.dataTask(with: url!) {(data, response, error) in
        
        if let jsondata = data {
            DispatchQueue.main.async {
                completion(JSON(data: jsondata))
            }
        }
    }
    
    task.resume()
    
}
