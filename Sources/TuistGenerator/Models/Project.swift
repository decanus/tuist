import Basic
import Foundation
import TuistCore

public class Project: Equatable, CustomStringConvertible {
    // MARK: - Attributes

    /// Path to the folder that contains the project manifest.
    public let path: AbsolutePath

    /// Project name.
    public let name: String

    /// Project file name.
    public let fileName: String

    /// Project targets.
    public let targets: [Target]

    /// Project schemes
    public let schemes: [Scheme]

    /// Project settings.
    public let settings: Settings

    /// The group to place project files within
    public let filesGroup: ProjectGroup

    /// Additional files to include in the project
    public let additionalFiles: [FileElement]

    // MARK: - Init

    /// Initializes the project with its attributes.
    ///
    /// - Parameters:
    ///   - path: Path to the folder that contains the project manifest.
    ///   - name: Project name.
    ///   - settings: The settings to apply at the project level
    ///   - filesGroup: The root group to place project files within
    ///   - targets: The project targets
    ///   - additionalFiles: The additional files to include in the project
    ///                      *(Those won't be included in any build phases)*
    public init(path: AbsolutePath,
                name: String,
                fileName: String? = nil,
                settings: Settings,
                filesGroup: ProjectGroup,
                targets: [Target],
                schemes: [Scheme],
                additionalFiles: [FileElement] = []) {
        self.path = path
        self.name = name
        self.fileName = fileName ?? name
        self.targets = targets
        self.schemes = schemes
        self.settings = settings
        self.filesGroup = filesGroup
        self.additionalFiles = additionalFiles
    }

    // MARK: - Init

    /// Returns a project model from the cache if present, otherwise loads a new instance.
    ///
    /// - Parameters:
    ///   - path: Path of the project
    ///   - cache: Cache instance to cache projects and dependencies.
    ///   - circularDetector: Utility to find circular dependencies between targets.
    ///   - modelLoader: Entity responsible for providing new instances of project models
    /// - Returns: Project instance.
    /// - Throws: An error if the project can't be loaded, or if circular dependencies are detected.
    static func at(_ path: AbsolutePath,
                   cache: GraphLoaderCaching,
                   circularDetector: GraphCircularDetecting,
                   modelLoader: GeneratorModelLoading) throws -> Project {
        if let project = cache.project(path) {
            return project
        } else {
            let project = try modelLoader.loadProject(at: path)
            cache.add(project: project)

            for target in project.targets {
                if cache.targetNode(path, name: target.name) != nil { continue }
                _ = try TargetNode.read(name: target.name, path: path, cache: cache, circularDetector: circularDetector, modelLoader: modelLoader)
            }

            return project
        }
    }

    /// It returns the project targets sorted based on the target type and the dependencies between them.
    /// The most dependent and non-tests targets are sorted first in the list.
    ///
    /// - Parameter graph: Dependencies graph.
    /// - Returns: Sorted targets.
    func sortedTargetsForProjectScheme(graph: Graphing) -> [Target] {
        return targets.sorted { (first, second) -> Bool in
            // First criteria: Test bundles at the end
            if first.product.testsBundle, !second.product.testsBundle {
                return false
            }
            if !first.product.testsBundle, second.product.testsBundle {
                return true
            }

            // Second criteria: Most dependent targets first.
            let secondDependencies = graph.targetDependencies(path: self.path, name: second.name)
                .filter { $0.path == self.path }
                .map { $0.target.name }
            let firstDependencies = graph.targetDependencies(path: self.path, name: first.name)
                .filter { $0.path == self.path }
                .map { $0.target.name }

            if secondDependencies.contains(first.name) {
                return true
            } else if firstDependencies.contains(second.name) {
                return false

                // Third criteria: Name
            } else {
                return first.name < second.name
            }
        }
    }

    // MARK: - CustomStringConvertible

    public var description: String {
        return name
    }

    // MARK: - Equatable

    public static func == (lhs: Project, rhs: Project) -> Bool {
        return lhs.path == rhs.path &&
            lhs.name == rhs.name &&
            lhs.targets == rhs.targets &&
            lhs.schemes == rhs.schemes &&
            lhs.settings == rhs.settings
    }
}
