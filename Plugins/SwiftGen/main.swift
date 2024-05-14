import PackagePlugin

@main struct SwiftGenPlugin: BuildToolPlugin {
    
    func createBuildCommands(context: PluginContext, target: Target) async throws -> [Command] {
        guard let sourceTarget = target as? SourceModuleTarget else { return [] }
        
        let arguments = [
            "--config",
            "\(context.package.directory.string)/swiftgen.yml",
        ]
        
        return [
            .prebuildCommand(
                displayName: "Running SwiftGen for \(target.name)",
                executable: try context.tool(named: "swiftgen").path,
                arguments: arguments,
                environment: [
                    "PROJECT_DIR": context.package.directory,
                    "TARGET_NAME": sourceTarget.name,
                    "PRODUCT_MODULE_NAME": sourceTarget.moduleName,
                    "DERIVED_SOURCES_DIR": context.pluginWorkDirectory
                ],
                outputFilesDirectory: context.pluginWorkDirectory
            )
        ]
    }
    
}
