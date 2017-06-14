//
//  GetMOTD.swift
//  DNMOTD
//
//  Created by ray on 31/05/2017.
//  Copyright © 2017 rayps. All rights reserved.
//

import Kanna

func getID(completion: @escaping (_ id: String) -> Void) {
    
    let url = URL(string: "https://www.designernews.co")
    
    let task = URLSession.shared.dataTask(with: url!) {(data, response, error) in
        if let html = data, let doc = HTML(html: html, encoding: .utf8) {
            if let result = doc.css("#feed-motd-container").first {
                let id = result["data-id"]!
                completion(id)
            }
        }
    }
    
    task.resume()
}


func getMOTD(completion: @escaping (_ motd: Any) -> Void) {
    
    getID { (id) in
        
        let url = URL(string: "https://api.designernews.co/api/v2/motds/\(id)")
        
        let task = URLSession.shared.dataTask(with: url!) {(data, response, error) in
            
            if let jsondata = data, let json = dataToJSON(data: jsondata) {
                completion(json)
            }
        }

        task.resume()
    }
}


func dataToJSON(data: Data) -> Any? {
    do {
        return try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
    } catch let myJSONError {
        print(myJSONError)
    }
    return nil
}
