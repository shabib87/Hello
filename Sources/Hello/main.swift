import Darwin
import Foundation

let fileManager = FileManager.default

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