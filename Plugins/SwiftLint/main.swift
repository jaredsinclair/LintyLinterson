import PackagePlugin
import Foundation

@main struct SwiftLintPlugin: BuildToolPlugin {
    
    /// Required by `BuildToolPlugin`.
    func createBuildCommands(context: PluginContext, target: Target) async throws -> [Command] {
        guard let sourceTarget = target as? SourceModuleTarget else { return [] }
        let inputFiles = sourceTarget.sourceFiles(withSuffix: "swift").map(\.path).map(\.string)
        guard inputFiles.isEmpty == false else { return [] }
        let workingDirectory = context.pluginWorkDirectory
        let arguments = arguments(
            configFile: "\(context.package.directory.string)/.swiftlint.yml",
            cachePath: workingDirectory,
            inputFiles: inputFiles
        )

        return [
            .prebuildCommand(
                displayName: "Running SwiftLint for \(target.name)",
                executable: try context.tool(named: "swiftlint").path,
                arguments: arguments,
                outputFilesDirectory: workingDirectory.appending("Output")
            )
        ]
    }

    /// Convenience method that composes the command line arguments for both
    /// package plugin and Xcode plugin use.
    ///
    /// - Parameters:
    ///   - configFile: The full path, filename, and extension for the SwiftLint
    ///     cofiguration `.yml` file.
    ///   - cachePath: The full file path to a directory where SwiftLint can
    ///     can its output for reuse. This is ignored when running in Xcode
    ///     Cloud because we do not have the necessary filesystem permissions.
    ///   - inputFiles: The array of input files to be linted. This can be
    ///     omitted for Xcode plugins, but is required for package plugins.
    ///
    /// - Returns: Returns an array of command line arguments.
    private func arguments(configFile: String, cachePath: Path, inputFiles: [String] = []) -> [String] {
        var arguments = [
            "lint",
            "--strict",
            "--quiet",
            "--config",
            configFile,
        ]

        // Determine whether we need to enable cache or not. For Xcode Cloud we
        // don't and, indeed, cannot, or else it will fail. See this:
        // https://github.com/realm/SwiftLint/pull/5287
        if ProcessInfo.processInfo.environment["CI_XCODE_CLOUD"] == "TRUE" {
            arguments.append("--no-cache")
        } else {
            arguments.append("--cache-path")
            arguments.append("\(cachePath)")
        }

        arguments.append(contentsOf: inputFiles)

        return arguments
    }

}

#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin

extension SwiftLintPlugin: XcodeBuildToolPlugin {
    
    /// Required by `XcodeBuildToolPlugin`.
    func createBuildCommands(context: XcodeProjectPlugin.XcodePluginContext, target: XcodeProjectPlugin.XcodeTarget) throws -> [PackagePlugin.Command] {
        let workingDirectory = context.pluginWorkDirectory
        let executable = try context.tool(named: "swiftlint").path
        let arguments = arguments(
            configFile: "\(context.xcodeProject.directory.string)/.swiftlint.yml",
            cachePath: workingDirectory
        )
        let outputFilesDirectory = workingDirectory.appending("Output")

        let commands = context.xcodeProject.targets.map { target in
            PackagePlugin.Command.prebuildCommand(
                displayName: "Running SwiftLint for \(target.displayName)",
                executable: executable,
                arguments: arguments,
                outputFilesDirectory: outputFilesDirectory
            )
        }
        
        return commands
    }
    
}
#endif
