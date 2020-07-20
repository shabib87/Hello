//
//  File.swift
//  
//
//  Created by Shabib Hossain on 2020-07-19.
//

import Foundation

func getLicenseFromLocalSPM() {
    do {
        let root = try fileManager.contentsOfDirectory(atPath: ".")
        var isDir : ObjCBool = false
        if root.contains(".build"),
            fileManager.fileExists(atPath: ".build", isDirectory:&isDir)
            {
                if isDir.boolValue {
                    let spm = try fileManager.contentsOfDirectory(atPath: ".build/")
                    if spm.contains("checkouts"),
                        fileManager.fileExists(atPath: ".build/checkouts", isDirectory:&isDir), isDir.boolValue {
                        let checkouts = try fileManager.contentsOfDirectory(atPath: ".build/checkouts")
                        try checkouts.forEach { package in
                            print(">>> \(package)")
                            let files = try fileManager.contentsOfDirectory(atPath: ".build/checkouts/\(package)")
                            try files.forEach { file in
                                if file.contains("LICENSE"),
                                    fileManager.fileExists(atPath: ".build/checkouts", isDirectory:&isDir), isDir.boolValue {
                                    let url = URL(fileURLWithPath: ".build/checkouts/\(package)/\(file)")
                                    let license = try String(contentsOf: url, encoding: .utf8)
                                    print(license)
                                }
                            }
                            print(">>>")
                        }
                    }
                }
        }
    } catch {
        print("coundn't read files: \(error.localizedDescription)")
    }
}
