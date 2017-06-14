//
//  GetMOTD.swift
//  DNMOTD
//
//  Created by ray on 31/05/2017.
//  Copyright © 2017 rayps. All rights reserved.
//

import Kanna
import SwiftyJSON

func getID(completion: @escaping (_ id: String) -> Void) {
    
    let url = URL(string: "https://www.designernews.co")
    
    let task = URLSession.shared.dataTask(with: url!) {(data, response, error) in
        if let html = data, let doc = HTML(html: html, encoding: .utf8) {
            if let result = doc.css("#feed-motd-container").first {
                let id = result["data-id"]!
                DispatchQueue.main.async {
                    completion(id)
                }
            }
        }
    }
    
    task.resume()
}


func getMOTD(completion: @escaping (_ json: JSON) -> Void) {
    
    getID { (id) in
        
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
}
