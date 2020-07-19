import Darwin
import Foundation

let fileManager = FileManager.default

// MARK: SPM
//fileManager.fileExists(atPath: ".", isDirectory: &true)
do {
    let root = try fileManager.contentsOfDirectory(atPath: ".")
    if root.contains(".build") {
        let spm = try fileManager.contentsOfDirectory(atPath: ".build/")
        if spm.contains("checkouts") {
            let checkouts = try fileManager.contentsOfDirectory(atPath: ".build/checkouts")
            try checkouts.forEach { package in
                let files = try fileManager.contentsOfDirectory(atPath: ".build/checkouts/\(package)")
                print(">>> \(package)")
                try files.forEach { file in
                    if file.contains("LICENSE") {
                        let url = URL(fileURLWithPath: ".build/checkouts/\(package)/\(file)")
                        let license = try String(contentsOf: url, encoding: .utf8)
                        print(license)
                    }
                }
                print(">>>")
            }
        }
    }
} catch {
    print("coundn't read files: \(error.localizedDescription)")
    exit(EXIT_FAILURE)
}

// MARK: POD

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
    
//    if root.contains("Pods") {
//        let pods = try fileManager.contentsOfDirectory(atPath: "Pods/")
//        try
//            pods.forEach { pod in
//            guard pod != ".DS_Store" else { return }
//            let files = try fileManager.contentsOfDirectory(atPath: "Pods/\(pod)")
//
//            print(">>> \(pod)")
//            try
//                files.forEach { file in
//                if file.contains("LICENSE") {
//                    let url = URL(fileURLWithPath: "Pods/\(pod)/\(file)")
//                    let license = try String(contentsOf: url, encoding: .utf8)
//                    print(license)
//                }
//                    print(file)
//            }
//            print(">>>")
//        }
//    }
} catch {
    print("coundn't read files: \(error.localizedDescription)")
    exit(EXIT_FAILURE)
}
