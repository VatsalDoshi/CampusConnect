//
//  APIUtils.swift
//  Assignment 9 Storyboard
//
//  Created by Vatsal Doshi on 11/27/23.
//

import Foundation

class APIUtils {
    static let baseURL: String = "https://6564cdd0ceac41c0761eda9c.mockapi.io"
    static let shared = APIUtils()
    
    // MARK: Colleges
    func getAllColleges(completion: @escaping ([College])->Void) {
        let session = URLSession(configuration: .default)
        
        // URL for items
        let urlString: String = APIUtils.baseURL + "/College"
        guard let url = URL(string: urlString) else {
            print("invalid URL")
            return
        }
        
        let request = URLRequest(url: url)
        
        // Check for API call
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error calling API \(error)")
                return
            }
            
            // Check for successful response
            if let response = response as? HTTPURLResponse {
                if response.statusCode == 200, let data = data {
                    do {
                        let items = try JSONDecoder().decode([College].self, from: data)
                        completion(items)
                    } catch let error {
                        print("Error parsing data: \(error)")
                    }

                    
                } else {
                    print("response error \(response.statusCode)")
                }
            }
        }
        task.resume()
    }
}



