import Foundation

enum ShellError: Error {
    case executionFailed(Int32, String)
    case timeout
}

actor ShellExecutor {
    static let shared = ShellExecutor()

    func execute(_ command: String, arguments: [String] = [], timeout: TimeInterval = 10) async throws -> String {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: command)
        process.arguments = arguments

        let pipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = pipe
        process.standardError = errorPipe

        try process.run()

        let timeoutTask = Task {
            try await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
            if process.isRunning {
                process.terminate()
            }
        }

        process.waitUntilExit()
        timeoutTask.cancel()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8) ?? ""

        if process.terminationStatus != 0 {
            let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
            let errorOutput = String(data: errorData, encoding: .utf8) ?? ""
            throw ShellError.executionFailed(process.terminationStatus, errorOutput)
        }

        return output
    }

    func executeWithStatus(_ command: String, arguments: [String] = [], timeout: TimeInterval = 10) async -> (output: String, exitCode: Int32) {
        do {
            let output = try await execute(command, arguments: arguments, timeout: timeout)
            return (output, 0)
        } catch ShellError.executionFailed(let code, let error) {
            return (error, code)
        } catch {
            return ("", -1)
        }
    }
}
