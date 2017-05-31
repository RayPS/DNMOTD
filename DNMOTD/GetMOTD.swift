//
//  GetMOTD.swift
//  DNMOTD
//
//  Created by ray on 31/05/2017.
//  Copyright © 2017 rayps. All rights reserved.
//

import Kanna

func get(completion: @escaping (_ message: String, _ author: String) -> Void) {
    
    let url = URL(string: "https://www.designernews.co")
    
    let task = URLSession.shared.dataTask(with: url!) {(data, response, error) in
        
        if let html = data, let doc = HTML(html: html, encoding: .utf8) {
            
            let message = doc.css("#feed-motd-message").first!.text!
            let author  = doc.css("#feed-motd-author a").first!.text!
            
            completion(message, author)
        }
    }
    
    task.resume()
}
