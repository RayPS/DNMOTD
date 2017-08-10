//
//  GetMOTD.swift
//  DNMOTD
//
//  Created by ray on 31/05/2017.
//  Copyright © 2017 rayps. All rights reserved.
//

import Kanna
import Haneke

var currentID: Int = 0
var latestID: Int = 0
var navigateDireaction: Int = -1

let motdsCache = Cache<JSON>(name: "motds")
let usersCache = Cache<JSON>(name: "users")

let dn_url = "https://www.designernews.co/"
let api_endpoint = dn_url + "api/v2/"


func getlatestID(completion: @escaping () -> Void) {
    
    let url = URL(string: dn_url)
    
    if let doc = HTML(url: url!, encoding: .utf8) {
        if let result = doc.at_css("#feed-motd-container") {
            let id = result["data-id"]!
            DispatchQueue.main.async {
                latestID = Int(id)!
                completion()
            }
        }
    }
}


func getMOTD(byID id: Int, completion: @escaping (_ data: Data) -> Void) {
    
    let url = URL(string: api_endpoint + "motds/\(id)")!

    let momentBeforeFetch = Date().timeIntervalSince1970

    motdsCache.fetch(URL: url).onSuccess { response in

        if response.asData().count != 35 {

            let fetchElapse = Date().timeIntervalSince1970 - momentBeforeFetch
            let duration = max(fetchElapse, 0.4)
            delay(delay: duration) {
                completion(response.asData())
            }
        } else {
            currentID += navigateDireaction
            print("MID: \(id) Has No Data! Retrying MID: \(currentID)...\n")
            getMOTD(byID: currentID){ response in
                completion(response.asData())
            }
        }
    }
}


func getUser(byID id: Int, completion: @escaping (_ data: Data) -> Void) {
    
    let url = URL(string: api_endpoint + "users/\(id)")!
    
    usersCache.fetch(URL: url).onSuccess { response in
        completion(response.asData())
    }
    
}
