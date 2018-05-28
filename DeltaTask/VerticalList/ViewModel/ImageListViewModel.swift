//
//  ImageListViewModel.swift
//  DeltaTask
//
//  Created by Dinesh Kumar on 27/05/18.
//  Copyright © 2018 Dinesh Kumar. All rights reserved.
//

import Foundation
import CoreData

class ImageListViewModel {
    
    var imagesArray  = [[String:AnyObject]]()
    
    /// Method - To retrieve all images from server from given image path
    ///
    /// - Parameter completion: <#completion description#>
    func getAllImages(completion:@escaping (_ imagesList: [[String:AnyObject]]?,_ error : Error?)->Void){
        let imageListApiPath = APIServices.getImagesList
        APIManager.shared.proceedRequestWith(apiPath: imageListApiPath, httpMethod: .get, completionSuccess: {[weak self] (response) in
            guard let _self = self else {return}
            guard let list  = response as? [[String:AnyObject]] else {
                return
            }
            _self.imagesArray = list
            //call back the image list response
            completion(list,nil)
        }) { (error) in
            completion(nil,error)
            //handling error here
        }
    }
}
