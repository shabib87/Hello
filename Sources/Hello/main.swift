import Darwin
import Foundation

let fileManager = FileManager.default

// MARK: xcode spm
//$PROJECT_FILE_PATH/project.xcworkspace/xcshareddata/swiftpm/
do {
    let swiftpm = try fileManager.contentsOfDirectory(atPath: "$PROJECT_FILE_PATH/")
    swiftpm.forEach {
        print($0)
    }
} catch {
    print("coundn't read files: \(error.localizedDescription)")
//    exit(EXIT_FAILURE)
}

// MARK: SPM
//do {
//    let root = try fileManager.contentsOfDirectory(atPath: ".")
//    var isDir : ObjCBool = false
//    if root.contains(".build"),
//        fileManager.fileExists(atPath: ".build", isDirectory:&isDir)
//        {
//            if isDir.boolValue {
//                let spm = try fileManager.contentsOfDirectory(atPath: ".build/")
//                if spm.contains("checkouts"),
//                    fileManager.fileExists(atPath: ".build/checkouts", isDirectory:&isDir), isDir.boolValue {
//                    let checkouts = try fileManager.contentsOfDirectory(atPath: ".build/checkouts")
//                    try checkouts.forEach { package in
//                        print(">>> \(package)")
//                        let files = try fileManager.contentsOfDirectory(atPath: ".build/checkouts/\(package)")
//                        try files.forEach { file in
//                            if file.contains("LICENSE"),
//                                fileManager.fileExists(atPath: ".build/checkouts", isDirectory:&isDir), isDir.boolValue {
//                                let url = URL(fileURLWithPath: ".build/checkouts/\(package)/\(file)")
//                                let license = try String(contentsOf: url, encoding: .utf8)
//                                print(license)
//                            }
//                        }
//                        print(">>>")
//                    }
//                }
//            }
//    }
//} catch {
//    print("coundn't read files: \(error.localizedDescription)")
//    exit(EXIT_FAILURE)
//}

// MARK: POD

//do {
//    let root = try fileManager.contentsOfDirectory(atPath: ".")
//    var isDir : ObjCBool = false
//
//    if root.contains("Pods"),
//        fileManager.fileExists(atPath: "Pods", isDirectory:&isDir) {
//        if isDir.boolValue {
//            // file exists and is a directory
//            let pods = try fileManager.contentsOfDirectory(atPath: "Pods/")
//            try pods.forEach { pod in
//                if fileManager.fileExists(atPath: "Pods/\(pod)", isDirectory: &isDir) {
//                    if isDir.boolValue {
//                        // file exists and is a directory
//                        print("<<<")
//                        print(pod)
//                        let files = try fileManager.contentsOfDirectory(atPath: "Pods/\(pod)")
//                        try files.forEach { file in
//                            if fileManager.fileExists(atPath: "Pods/\(pod)/\(file)", isDirectory:&isDir) {
//                                if !isDir.boolValue,
//                                 file.contains("LICENSE") {
//                                    let url = URL(fileURLWithPath: "Pods/\(pod)/\(file)")
//                                    let license = try String(contentsOf: url, encoding: .utf8)
//                                    print(license)
//                                }
//                            }
//                        }
//                        print(">>>")
//                    }
//                }
//            }
//        } else {
//            // file exists and is not a directory
//        }
//    } else {
//        // file does not exist
//    }
//} catch {
//    print("coundn't read files: \(error.localizedDescription)")
//    exit(EXIT_FAILURE)
//}
