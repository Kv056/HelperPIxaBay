//
//  HelperPixabay.swift
//
//
//  Created by KIRTAN VAGHELA on 16/04/19.
//  Copyright © 2019 KV. All rights reserved.
//

import UIKit

//use this type alias to identify parameter as reciver side.
typealias thumbImageUrl = String
typealias fullImageUrl = String
typealias videoURL = String

class HelperPixabay: NSObject {

    static var shared : HelperPixabay = HelperPixabay()
    private let pixabayDefaultSearchKeyword = "Nature" //if search keyword is nil
    
    func callAPI(apiUrl:URL,completion: @escaping (NSDictionary?,Error?) -> ()) -> (){
        let task = URLSession.shared.dataTask(with: apiUrl) { (data, response, error) in
            if error != nil {
                completion (nil, error)
                print(error ?? " ")
            } else {
                DispatchQueue.main.async(execute: {
                    do{
                        if data != nil{
                            
                            let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as? NSDictionary
                            
                            if let parseJSON = json {
                                
                                // print(parseJSON)
                                // Parsed JSON
                                completion (parseJSON,nil)
                                // completion(_responseData:parseJSON,Error:error)
                                
                            }
                            else {
                                // Woa, okay the json object was nil, something went worng. Maybe the server isn't running?
                                let jsonStr = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                                
                                #if DEBUG
                                print("Error could not parse JSON: \(String(describing: jsonStr))")
                                #endif
                            }
                        }else{
                            print(error?.localizedDescription ?? " ")
                            completion (nil, error!)
                        }
                        
                    }catch let error as NSError{
                        
                        print(error.localizedDescription)
                        completion (nil, error)
                    }
                })
            }
        }
        task.resume()
    }
    
    func getPixaBayImages(searchKeyword:String,apiKey:String,completion: @escaping (_ arrThumbImageURL:[thumbImageUrl]?,_ arrFullImageURL:[fullImageUrl]?,_ error:Error?)-> Void) {
        var query = ""
        
        if !searchKeyword.isEmpty && searchKeyword.first! != " " {
            query = searchKeyword
        }else{
            query = pixabayDefaultSearchKeyword
        }
        query = (query).replacingOccurrences(of: " ", with: "+")
        
        var arrThumbImagesUrl = [String]()
        var arrFullImagesUrl = [String]()
        let url = "https://pixabay.com/api/?key=\(apiKey)&q=\(query)&per_page=200&safesearch=true"
        
        self.callAPI(apiUrl: URL (string: url)!) { (response, error) in
            if response != nil && error == nil{
                if  let responseData = response!["hits"] as? Array<Dictionary<String, AnyObject>>{
                    for index in 0..<responseData.count{
                        let thumbURL = responseData[index]["previewURL"] as? String
                        let fullURL = responseData[index]["webformatURL"] as? String
                        arrThumbImagesUrl.append(thumbURL!)
                        arrFullImagesUrl.append(fullURL!)
                    }
                    if arrThumbImagesUrl.count > 0{
                        completion (arrThumbImagesUrl, arrFullImagesUrl, nil)
                    }else{
                        completion (arrThumbImagesUrl, arrFullImagesUrl, nil)
                    }
                }else{
                    completion (nil, nil, error)
                }
               
            }else{
                completion (nil, nil, error)
            }
        }
    }
    
    
    func getPixaBayVideos(searchKeyword:String,apiKey:String,completion: @escaping (_ arrThumbImgURL:[thumbImageUrl]?,_ arrVideoURL:[videoURL]?,_ error:Error?)-> Void){
        var query = ""
        
        if !searchKeyword.isEmpty && searchKeyword.first! != " "{
            query = searchKeyword
        }else{
            query = pixabayDefaultSearchKeyword
        }
        query = (query).replacingOccurrences(of: " ", with: "+")
        
        var arrVideoURL = [String]()
        var arrThumbImgURL = [String]()
        
        let url = "https://pixabay.com/api/videos/?key=\(pixaBayAPIKEY)&q=\(query)&per_page=200&safesearch=true&download=1"
        
        self.callAPI(apiUrl: URL (string: url)!) { (response, error) in
            if response != nil && error == nil{
                let responseData = response!["hits"] as? Array<Dictionary<String, AnyObject>>
                for index in 0..<responseData!.count{
                    let pictureID = responseData![index]["picture_id"] as? String
                    let dictVideos = responseData![index]["videos"]
                    let infoMediumVideoDict = dictVideos!["medium"] as? Dictionary<String,Any>
                    let videoURL = infoMediumVideoDict!["url"] as? String
                    arrThumbImgURL.append("https://i.vimeocdn.com/video/\(pictureID ?? "")_640x360.jpg")
                    arrVideoURL.append(videoURL!)
                }
                completion (arrThumbImgURL, arrVideoURL, nil)
            }else{
                completion (arrThumbImgURL,arrVideoURL, error)
            }
        }
    }
}
