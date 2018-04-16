//
//  Configuration+LintableFiles.swift
//  SwiftLint
//
//  Created by JP Simard on 7/17/17.
//  Copyright © 2017 Realm. All rights reserved.
//

import Foundation
import SourceKittenFramework

extension Configuration {
    public func lintableFiles(inPath path: String, forceExclude: Bool) -> [File] {
        return lintablePaths(inPath: path, forceExclude: forceExclude).compactMap(File.init(pathDeferringReading:))
    }

    public func lintableFiles(ofFiles files: [File]) -> [File] {
        let excludedPaths = excluded.flatMap {
            FileManager.default.filesToLint(inPath: $0, rootDirectory: rootPath)
        }
        return files.filter {
            guard let path = $0.path else {
                return true
            }
            return !excludedPaths.contains(path)
        }
    }

    internal func lintablePaths(inPath path: String, forceExclude: Bool,
                                fileManager: LintableFileManager = FileManager.default) -> [String] {
        // If path is a file and we're not forcing excludes, skip filtering with excluded/included paths
        if path.isFile && !forceExclude {
            return [path]
        }
        let pathsForPath = included.isEmpty ? fileManager.filesToLint(inPath: path, rootDirectory: nil) : []
        let excludedPaths = excluded.flatMap {
            fileManager.filesToLint(inPath: $0, rootDirectory: rootPath)
        }
        let includedPaths = included.flatMap {
            fileManager.filesToLint(inPath: $0, rootDirectory: rootPath)
        }
        return (pathsForPath + includedPaths).filter {
            !excludedPaths.contains($0)
        }
    }
}
