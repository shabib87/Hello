//
//  File.swift
//  
//
//  Created by Shabib Hossain on 2020-07-19.
//

import Foundation

func getLicensenseFromCocopod() {
    do {
        let root = try fileManager.contentsOfDirectory(atPath: ".")
        var isDir : ObjCBool = false

        if root.contains("Pods"),
            fileManager.fileExists(atPath: "Pods", isDirectory:&isDir) {
            if isDir.boolValue {
                // file exists and is a directory
                let pods = try fileManager.contentsOfDirectory(atPath: "Pods/")
                try pods.forEach { pod in
                    if fileManager.fileExists(atPath: "Pods/\(pod)", isDirectory: &isDir) {
                        if isDir.boolValue {
                            // file exists and is a directory
                            print("<<<")
                            print(pod)
                            let files = try fileManager.contentsOfDirectory(atPath: "Pods/\(pod)")
                            try files.forEach { file in
                                if fileManager.fileExists(atPath: "Pods/\(pod)/\(file)", isDirectory:&isDir) {
                                    if !isDir.boolValue,
                                     file.contains("LICENSE") {
                                        let url = URL(fileURLWithPath: "Pods/\(pod)/\(file)")
                                        let license = try String(contentsOf: url, encoding: .utf8)
                                        print(license)
                                    }
                                }
                            }
                            print(">>>")
                        }
                    }
                }
            } else {
                // file exists and is not a directory
            }
        } else {
            // file does not exist
        }
    } catch {
        print("coundn't read files: \(error.localizedDescription)")
    }
}
