//
//  BikeDetail.swift
//  CityBike
//
//  Created by Maharani on 15/12/17.
//  Copyright © 2017 Maharani SVS. All rights reserved.
//

import UIKit
import CoreLocation

// MARK: - Alias Names
typealias CityBikeDict = [String:Any]
typealias CityBikeArray = [CityBikeDict]
typealias CityBikeAny = [Any]


// MARK: - Singleton Class
class Singleton {
    
    //Shared Instance Creation
    static let sharedInstance: Singleton = {
        let instance = Singleton()
        return instance
    }()

    // MARK: - Class Functions
    class func getDictionaryValuesFromKeys(dict: [String:Any] , key: String) -> String {
        return nilOrNullcheck(name: dict[key , default: ""] as? String)
    }

    class func nilOrNullcheck(name:String?) -> String
    {
        return (name != nil ) && self.isNull(someObject: name!) ? name! : ""
    }

    class func isNull(someObject: Any?) -> Bool {
        return (someObject is NSNull) ? false : true
    }

    public class func  GetListCountfromDict(objectName: String, isList: CityBikeDict) -> CityBikeArray {
        let isValidObject: Bool = self.nullToBool(value: isList[objectName])
        return  isValidObject ?isList[objectName , default: []] as! CityBikeArray  : []
    }

    public class func  GetStringfromDict(objectName: String, isList: CityBikeDict) -> CityBikeAny {
        let isValidObject: Bool = self.nullToBool(value: isList[objectName])
        return  isValidObject ? isList[objectName , default: []] as! CityBikeAny : []
    }

    public class func nullToBool(value : Any?) -> Bool {
        if value is NSNull || value == nil {
            return false
        } else {
            return true
        }
    }
    class func nullToNil(value : Any?) -> Any? {
        if value is NSNull || value == nil {
            return "" as Any?
        } else {
            if let a = value as? NSNumber {
                return a.stringValue
            } else {
                return (value as! String).uppercased() == "NULL"  ? "" : value
            }
        }
    }

}

// MARK: - Company Class

class Company {
    var companyList: Array<String>?
    init(companyList: Array<String>) {
        for companyName in companyList {
            self.companyList?.append(companyName)
        }
    }
}

// MARK: - Location Class
class Location {
    var getLocation : CLLocationCoordinate2D?, country: String?  , city: String?

    init(LocationDict: [String : Any]) {
        self.getLocation = CLLocationCoordinate2D.init(latitude: LocationDict[APIKeys.latitudePoint.rawValue] as! CLLocationDegrees, longitude: LocationDict[APIKeys.longitudePoint.rawValue] as! CLLocationDegrees)
        self.country = LocationDict[APIKeys.countryName.rawValue] as? String
        self.city = LocationDict[APIKeys.cityName.rawValue] as? String
    }
}

// MARK: - Stations Class
class Stations {
    
    var emptySlots : String? ,freeBikes : String?,stationName : String? ,locationDetails : CLLocationCoordinate2D?
    init(stationObject : [String :Any]) {
        self.emptySlots = String(describing: stationObject[APIKeys.emptySlots.rawValue]!)
        self.freeBikes = String(describing: stationObject[APIKeys.freebikes.rawValue]!)
        self.stationName = stationObject[APIKeys.bikeName.rawValue] as? String
        self.locationDetails = CLLocationCoordinate2D.init(latitude: stationObject[APIKeys.latitudePoint.rawValue] as! CLLocationDegrees, longitude: stationObject[APIKeys.longitudePoint.rawValue] as! CLLocationDegrees)
       
    }
}
// MARK: - BikeDetail Class
class BikeDetail {
    var bikeId: String? , imgLink: String? , bikeName : String?, companyList: Company?, locationDetails : Location
    init (bikeObject : [String : Any]) {
        self.bikeId = bikeObject[APIKeys.bikeId.rawValue] as? String
        self.imgLink = bikeObject[APIKeys.imgLink.rawValue] as? String
        self.bikeName = bikeObject[APIKeys.bikeName.rawValue] as? String
        self.locationDetails = Location(LocationDict: bikeObject[APIKeys.location.rawValue] as! [String : Any])
        let isEss = Singleton.getDictionaryValuesFromKeys(dict: bikeObject, key: APIKeys.companyName.rawValue)
        if isEss.isEmpty == false {
            self.companyList =  Company(companyList: [isEss])
        }
        else {
            let isEdit = Singleton.GetStringfromDict(objectName: APIKeys.companyName.rawValue, isList: bikeObject)
            guard isEdit.isEmpty == false else {
                return
            }
            if let stringArray = bikeObject[APIKeys.companyName.rawValue] as? Array<String> {
                self.companyList =  Company(companyList: stringArray)
            }
        }
   }
}
