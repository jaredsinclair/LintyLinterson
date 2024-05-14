import Foundation
import PackagePlugin

@main struct HeaderCopyrightPlugin: CommandPlugin {
    
    func performCommand(context: PluginContext, arguments: [String]) throws {
        let tool = try context.tool(named: "swiftformat")
        let toolUrl = URL(fileURLWithPath: tool.path.string)
        
        for target in context.package.targets {
            guard let target = target as? SourceModuleTarget else { continue }
            
            let process = Process()
            process.executableURL = toolUrl
            process.arguments = [
                "\(target.directory)",
                "--config", "header.swiftformat",
                "--verbose"
            ]
            
            try process.run()
            process.waitUntilExit()
            
            if process.terminationReason == .exit && process.terminationStatus == 0 {
                print("Formatted the source code in \(target.directory).")
            }
            else {
                let problem = "\(process.terminationReason):\(process.terminationStatus)"
                Diagnostics.error("swift-format invocation failed: \(problem)")
            }
        }
    }
    
}

#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin

extension HeaderCopyrightPlugin: XcodeCommandPlugin {
    
    func performCommand(context: XcodePluginContext, arguments: [String]) throws {
        let tool = try context.tool(named: "swiftformat")
        let toolUrl = URL(fileURLWithPath: tool.path.string)
        
        for target in context.xcodeProject.targets {
            var fileList = [String]()
            for file in target.inputFiles {
                guard file.path.extension == "swift" else { continue }
                fileList.append(file.path.string)
            }
            
            let process = Process()
            process.executableURL = toolUrl
            process.arguments = [
                "\(fileList.joined(separator: ", "))",
                "--config", "header.swiftformat",
                "--verbose"
            ]
            
            try process.run()
            process.waitUntilExit()
            
            if process.terminationReason == .exit && process.terminationStatus == 0 {
                print("Formatted the source code in \(target.displayName).")
            }
            else {
                let problem = "\(process.terminationReason):\(process.terminationStatus)"
                Diagnostics.error("swift-format invocation failed: \(problem)")
            }
        }
    }
    
}
#endif
