//
//  File.swift
//  
//
//  Created by Shabib Hossain on 2020-07-19.
//

import Foundation

struct WrappedPackageItems: Decodable {
    let object: PackageItems
}

struct PackageItems: Decodable {
    let pins: [PackageObj]
}

struct PackageObj: Decodable {
    let package: String
    let repositoryURL: String
    let state: PackageObjState
}

struct PackageObjState: Decodable {
    let version: String
}

struct LicenseInfo: Decodable {
    let downloadUrl: String
}
