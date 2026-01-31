import Foundation

private final class ExecutionContext: @unchecked Sendable {
    private var stdoutData = Data()
    private var stderrData = Data()
    private var hasResumed = false
    private let lock = NSLock()

    func appendStdout(_ data: Data) {
        lock.lock()
        stdoutData.append(data)
        lock.unlock()
    }

    func appendStderr(_ data: Data) {
        lock.lock()
        stderrData.append(data)
        lock.unlock()
    }

    var stdoutString: String {
        lock.lock()
        defer { lock.unlock() }
        return String(data: stdoutData, encoding: .utf8) ?? ""
    }

    var stderrString: String {
        lock.lock()
        defer { lock.unlock() }
        return String(data: stderrData, encoding: .utf8) ?? ""
    }

    func safeResume(_ continuation: CheckedContinuation<String, Error>, _ result: Result<String, Error>) {
        lock.lock()
        defer { lock.unlock() }
        guard !hasResumed else { return }
        hasResumed = true
        continuation.resume(with: result)
    }
}

enum ShellError: Error, LocalizedError {
    case executionFailed(Int32, String)
    case timeout
    case terminated

    var errorDescription: String? {
        switch self {
        case .executionFailed(let code, let stderr):
            return stderr.isEmpty ? "Exit code \(code)" : stderr.trimmingCharacters(in: .whitespacesAndNewlines)
        case .timeout:
            return "Command timed out"
        case .terminated:
            return "Command was terminated"
        }
    }
}

actor ShellExecutor {
    static let shared = ShellExecutor()

    func execute(_ command: String, arguments: [String] = [], timeout: TimeInterval = 10) async throws -> String {
        let context = ExecutionContext()

        return try await withCheckedThrowingContinuation { continuation in
            let process = Process()
            process.executableURL = URL(fileURLWithPath: command)
            process.arguments = arguments

            let stdoutPipe = Pipe()
            let stderrPipe = Pipe()
            process.standardOutput = stdoutPipe
            process.standardError = stderrPipe

            // Read stdout incrementally to prevent buffer deadlock
            stdoutPipe.fileHandleForReading.readabilityHandler = { [context] handle in
                let data = handle.availableData
                if !data.isEmpty {
                    context.appendStdout(data)
                }
            }

            stderrPipe.fileHandleForReading.readabilityHandler = { [context] handle in
                let data = handle.availableData
                if !data.isEmpty {
                    context.appendStderr(data)
                }
            }

            // Timeout handler
            let timeoutWork = DispatchWorkItem { [weak process] in
                process?.terminate()
            }
            DispatchQueue.global().asyncAfter(deadline: .now() + timeout, execute: timeoutWork)

            // Termination handler (non-blocking)
            process.terminationHandler = { [context, timeoutWork] proc in
                timeoutWork.cancel()

                // Stop reading handlers
                stdoutPipe.fileHandleForReading.readabilityHandler = nil
                stderrPipe.fileHandleForReading.readabilityHandler = nil

                // Read any remaining data
                context.appendStdout(stdoutPipe.fileHandleForReading.readDataToEndOfFile())
                context.appendStderr(stderrPipe.fileHandleForReading.readDataToEndOfFile())

                let output = context.stdoutString
                let errorOutput = context.stderrString

                if proc.terminationReason == .uncaughtSignal {
                    context.safeResume(continuation, .failure(ShellError.timeout))
                } else if proc.terminationStatus != 0 {
                    context.safeResume(continuation, .failure(ShellError.executionFailed(proc.terminationStatus, errorOutput)))
                } else {
                    context.safeResume(continuation, .success(output))
                }
            }

            do {
                try process.run()
            } catch {
                timeoutWork.cancel()
                context.safeResume(continuation, .failure(error))
            }
        }
    }

    func executeWithStatus(_ command: String, arguments: [String] = [], timeout: TimeInterval = 10) async -> (output: String, exitCode: Int32, error: String?) {
        do {
            let output = try await execute(command, arguments: arguments, timeout: timeout)
            return (output, 0, nil)
        } catch let shellError as ShellError {
            switch shellError {
            case .executionFailed(let code, let stderr):
                return (stderr, code, shellError.errorDescription)
            case .timeout:
                return ("", -1, "Command timed out")
            case .terminated:
                return ("", -1, "Command was terminated")
            }
        } catch {
            return ("", -1, error.localizedDescription)
        }
    }
}
