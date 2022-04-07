//
//  MacMenuAppApp.swift
//  MacMenuApp
//
//  Created by Attila Szél on 2022. 04. 05..
//

import SwiftUI
import MusicPlayer

@main
struct NPMenuBarApp: App {
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    
    // MARK: - Properties
    
    var statusItem: NSStatusItem?
    var popOver = NSPopover()
    public var lastStatusTitle: String = ""
    
    private var musicPlayerManager: MusicPlayerManager!
    private var viewModel: MenuBarViewModel = MenuBarViewModel()
    
    private lazy var contentView: NSView? = {
        let view = (statusItem?.value(forKey: "window") as? NSWindow)?.contentView
        return view
    }()
    
    // MARK: - AppDelegate methods
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Close the main app window (but it should not be opened anyway)
        if let window = NSApplication.shared.windows.first {
            window.close()
        }
        
        // The player
        
        musicPlayerManager = MusicPlayerManager()
        musicPlayerManager.add(musicPlayer: .spotify)
        
        musicPlayerManager.delegate = self
        
        viewModel.setupMusicPlayer(musicPlayerManager)
        
        statusItem = NSStatusBar.system.statusItem(withLength: 256)
        guard let contentView = self.contentView, let menuButton = statusItem?.button else { return }
        
        let hostingView = NSHostingView(rootView: ScrollingTextView(viewModel: viewModel))
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(hostingView)
        
        NSLayoutConstraint.activate([
            hostingView.topAnchor.constraint(equalTo: contentView.topAnchor),
            hostingView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            hostingView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            hostingView.leftAnchor.constraint(equalTo: contentView.leftAnchor)
        ])
        
        menuButton.action = #selector(MenuButtonToggle)
        
        setupPopover()
        updateTitle()
    }
    
    // MARK: - Private functions
    
    
    // TODO: (Attila) - Make the popOver show on right click (or some other view? -- maybe to exit the app)
    @objc func MenuButtonToggle(sender: AnyObject) {
        if popOver.isShown {
            popOver.performClose(sender)
            return
        } else {
            guard let menuButton = statusItem?.button else { return }
            let positioningView = NSView(frame: menuButton.bounds)
            positioningView.identifier = NSUserInterfaceItemIdentifier("positioningView")
            menuButton.addSubview(positioningView)
            
            popOver.show(relativeTo: menuButton.bounds, of: menuButton, preferredEdge: .maxY)
            menuButton.bounds = menuButton.bounds.offsetBy(dx: 0, dy: menuButton.bounds.height)
            popOver.contentViewController?.view.window?.makeKey()
        }
    }
    
    @objc func updateTitle() {
        viewModel.updateView()
        Console.info("Track change detected.")
    }
}

extension AppDelegate: MusicPlayerManagerDelegate {
    func manager(_: MusicPlayerManager, trackingPlayer _: MusicPlayer, didChangeTrack _: MusicTrack, atPosition _: TimeInterval) {
        updateTitle()
    }

    func manager(_: MusicPlayerManager, trackingPlayer _: MusicPlayer, playbackStateChanged _: MusicPlaybackState, atPosition _: TimeInterval) {
        updateTitle()
    }

    func manager(_: MusicPlayerManager, trackingPlayerDidQuit _: MusicPlayer) {
        updateTitle()
    }

    func manager(_: MusicPlayerManager, trackingPlayerDidChange player: MusicPlayer) {
        return
    }
}

// MARK: - PopOver

extension AppDelegate: NSPopoverDelegate {
    
    func setupPopover() {
        popOver.behavior = .transient
        popOver.animates = true
        popOver.contentSize = .init(width: 240, height: 280)
        popOver.contentViewController = NSViewController()
        popOver.contentViewController?.view = NSHostingView(rootView: ContentView())
        popOver.delegate = self
    }
    
    func popoverDidClose(_ notification: Notification) {
        let positioningView = statusItem?.button?.subviews.first {
            $0.identifier == NSUserInterfaceItemIdentifier("positioningView")
        }
        positioningView?.removeFromSuperview()
    }
    
}
