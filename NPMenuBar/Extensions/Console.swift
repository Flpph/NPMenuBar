//
//  Console.swift
//  Copyright © 2016 Grant Davis Interactive, LLC. All rights reserved.
//

import Foundation
import os


// MARK: - Context

public struct ConsoleContext {
    let message: ConsoleMessage
    let channel: ConsoleChannel
    let formatter: ConsoleFormatter
}


// MARK: - Message

public struct ConsoleMessage {
    let filepath: String
    let function: String
    let line: Int
    let content: String
}


// MARK: - Channel

public struct ConsoleChannel: Codable, Hashable {
    public let identifier: String
    public let name: String
    public let emoji: String
    public let osLogTypeRawValue: UInt8
    public let isSystem: Bool

    public func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }

    public var osLogType: OSLogType {
        return OSLogType(rawValue: osLogTypeRawValue)
    }

    @available(tvOS 10.0, *)
    public init(name: String, emoji: String, osLogType: OSLogType) {
        self.identifier = emoji + name
        self.name = name
        self.emoji = emoji
        self.osLogTypeRawValue = osLogType.rawValue
        self.isSystem = false
    }

    public init(name: String, emoji: String) {
        self.identifier = emoji + name
        self.name = name
        self.emoji = emoji
        self.osLogTypeRawValue = 0
        self.isSystem = false
    }

    internal init(systemChannel: Console.Channel) {
        self.identifier = systemChannel.rawValue
        self.name = systemChannel.name
        self.emoji = systemChannel.emoji ?? ""
        self.osLogTypeRawValue = systemChannel.osLogType.rawValue
        self.isSystem = true
    }
}


// MARK: - Formatter

public protocol ConsoleFormatter {
    func print(_ context: ConsoleContext)
}


// MARK: - Console

public struct Console {
    public enum Channel: String, CaseIterable {
        case debug
        case verbose
        case information
        case warning
        case error

        public var consoleChannel: ConsoleChannel {
            return ConsoleChannel(systemChannel: self)
        }

        @available(tvOS 10.0, *)
        public var osLogType: OSLogType {
            switch self {
            case .debug:
                return .debug
            case .verbose:
                return .default
            case .information, .warning:
                return .info
            case .error:
                return .error
            }
        }

        public var name: String {
            switch self {
            case .debug:
                return "Debug"
            case .verbose:
                return "Verbose"
            case .information:
                return "Information"
            case .warning:
                return "Warning"
            case .error:
                return "Error"
            }
        }

        public var emoji: String? {
            switch self {
            case .debug:
                return "🛠"
            case .verbose:
                return "📋"
            case .information:
                return "💬"
            case .warning:
                return "⚠️"
            case .error:
                return "⛔️"
            }
        }
    }

    public static func log(_ message: String, channel: ConsoleChannel? = nil, formatter: ConsoleFormatter? = nil, filename: String = #file, line: Int = #line, functionName: String = #function) {
        let message = ConsoleMessage(filepath: filename, function: functionName, line: line, content: message)
        let context = ConsoleContext(
            message: message,
            channel: channel ?? defaultChannel,
            formatter: formatter ?? defaultFormatter
        )

        log(context)
    }

    public static func log(_ message: String, channel: Console.Channel, formatter: ConsoleFormatter? = nil, filename: String = #file, line: Int = #line, functionName: String = #function) {
        log(message,
            channel: channel.consoleChannel,
            formatter: formatter,
            filename: filename,
            line: line,
            functionName: functionName
        )
    }

    private static var disabledUserChannels: [ConsoleChannel] {
        return disabledChannels.filter { $0.isSystem == false }
    }

    public static var allUserChannels: [ConsoleChannel] {
        let channels = userChannels.map { $0.value } + disabledUserChannels
        return channels.unique
    }

    private(set) public static var userChannels = [String: ConsoleChannel]() {
        didSet {
            Notification.Name.userChannelsChanged.postOnMainThread()
        }
    }
    
    private static var serialQueue = {
        return DispatchQueue(label: "Console Serial Queue")
    }()

    public static func log(_ context: ConsoleContext) {
        if context.channel.isSystem == false {
            serialQueue.sync {
                self.userChannels[context.channel.identifier] = context.channel
            }
        }

        #if DEBUG
        context.formatter.print(context)
        #else
        defaultOSLogFormatter.print(context)
        #endif
    }

    // MARK: - Settings

    private class Settings: Codable {
        static var `default`: Settings = {
            return Settings(disabledChannels: [])
        }()

        var disabledChannels: Set<ConsoleChannel>

        init(disabledChannels: [ConsoleChannel]) {
            self.disabledChannels = Set<ConsoleChannel>(disabledChannels)
        }
    }

    //MARK: - Properties

    internal static var disabledChannels: [ConsoleChannel] {
        return Array(settings.disabledChannels)
    }

    private static let defaultsKey = "Console.Settings.DefaultsKey"

    private static var defaults: UserDefaults {
        return UserDefaults.standard
    }

    private static var settings: Settings = {
        return load() ?? Settings.default
    }()


    //MARK: - Methods

    public static func isEnabled(_ channel: ConsoleChannel) -> Bool {
        return !settings.disabledChannels.contains(channel)
    }

    public static func enable(_ channel: ConsoleChannel) {
        settings.disabledChannels.remove(channel)
        save()
    }

    public static func disable(_ channel: ConsoleChannel) {
        guard settings.disabledChannels.contains(channel) == false else { return }
        settings.disabledChannels.insert(channel)
        userChannels.removeValue(forKey: channel.identifier)
        save()
    }

    public static func toggle(channel: ConsoleChannel) {
        if isEnabled(channel) {
            disable(channel)
        } else {
            enable(channel)
        }
    }

    private static func load() -> Settings? {
        guard let data = defaults.data(forKey: defaultsKey) else {
            return nil
        }
        
        do {
            let storedSettings = try JSONDecoder().decode(Settings.self, from: data)
            return storedSettings
        } catch {
            Console.error("Failed to load stored settings with error: \(error)")
            assertionFailure("Failed to load stored settings with error: \(error)")
        }
        
        return nil
    }

    fileprivate static func save() {
        do {
            let data = try JSONEncoder().encode(settings)
            defaults.set(data, forKey: defaultsKey)

            if defaults.synchronize() {
                Notification.Name.consoleChannelsChanged.postOnMainThread()
            } else {
                Console.error("Failed to synchronize log settings to defaults!")
            }
        } catch {
            Console.error("Failed to save log settings! Error: \(error)")
        }
    }
}

// MARK: - Notification

public extension Notification.Name {
    static let consoleChannelsChanged = Notification.Name(rawValue: "Console.consoleChannelsChanged")
    static let userChannelsChanged = Notification.Name(rawValue: "Console.userChannelsChanged")
}

// MARK: - Default Formatters

private extension Console {

    private static var defaultChannel: ConsoleChannel {
        return Console.Channel.verbose.consoleChannel
    }

    private static var defaultFormatter: ConsoleFormatter = {
        return GenericMessageFormatter()
    }()

    private static var defaultOSLogFormatter: ConsoleFormatter = {
        return OSLogFormatter()
    }()

}

// MARK: - Shortcut Methods for Built-in Channels

public extension Console {
    static func debug(_ message: String, filename: String = #file, line: Int = #line, functionName: String = #function) {
        Console.log(message, channel: .debug, filename: filename, line: line, functionName: functionName)
    }

    static func verbose(_ message: String, filename: String = #file, line: Int = #line, functionName: String = #function) {
        Console.log(message, channel: .verbose, filename: filename, line: line, functionName: functionName)
    }

    static func info(_ message: String, filename: String = #file, line: Int = #line, functionName: String = #function) {
        Console.log(message, channel: .information, filename: filename, line: line, functionName: functionName)
    }

    static func warn(_ message: String, filename: String = #file, line: Int = #line, functionName: String = #function) {
        Console.log(message, channel: .warning, filename: filename, line: line, functionName: functionName)
    }

    static func error(_ message: String, filename: String = #file, line: Int = #line, functionName: String = #function) {
        Console.log(message, channel: .error, filename: filename, line: line, functionName: functionName)
    }
}


// MARK: - Built-in Formatters

private struct GenericMessageFormatter: ConsoleFormatter {
    func print(_ context: ConsoleContext) {
        #if DEBUG
        guard Console.isEnabled(context.channel) else { return }

        let icon = "\(context.channel.emoji) "
        let filename = URL(fileURLWithPath: context.message.filepath).lastPathComponent
        let string = "\(icon)\(filename):\(context.message.line) -> \(context.message.content)"

        Swift.print(string)
        #endif
    }
}

private struct OSLogFormatter: ConsoleFormatter {
    func print(_ context: ConsoleContext) {
        if #available(tvOS 10.0, *) {
            os_log("%{public}@%{public}@:%d -> %{public}@", log: .default, type: context.channel.osLogType, context.channel.emoji, context.message.filepath, context.message.line, context.message.content)
        }
    }
}
