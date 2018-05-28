//
//  ImageDataModel+CoreDataProperties.swift
//  
//
//  Created by Dinesh Kumar 16 on 5/28/18.
//
//

import Foundation
import CoreData


extension ImageDataModel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ImageDataModel> {
        return NSFetchRequest<ImageDataModel>(entityName: "ImageDataModel")
    }

    @NSManaged public var rank: Int64?
    @NSManaged public var email: String?
    @NSManaged public var id: Int64
    @NSManaged public var image: String?
    @NSManaged public var name: String?

}
