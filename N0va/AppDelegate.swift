//
//  AppDelegate.swift
//  Wallpaper
//
//  Created by Plumk on 2021/4/25.
//

import Cocoa

// UserDefaults last record key
let kLastWallpaper = "kLastWallpaper"

let WallpaperDidChangeNotification: Notification.Name = .init(rawValue: "WallpaperDidChangeNotification")

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    var model: WallpaperModel? {
        didSet {
            if oldValue != self.model {
                NotificationCenter.default.post(name: WallpaperDidChangeNotification, object: nil)
                
                self.wallpaperWindowDict.forEach({
                    $0.value.reload(self.model)
                })
            }
        }
    }
    
    var preScreensHashValue: Int = 0
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        self.createStatusMenuItem()
        self.reloadWallpaperWindows()
        
        self.reloadCache()
        
        /// - 监听screens 变化
        self.preScreensHashValue = NSScreen.screens.hashValue
        let observer = CFRunLoopObserverCreateWithHandler(kCFAllocatorDefault, CFRunLoopActivity.afterWaiting.rawValue, true, 0) { _, _ in
            let hashValue = NSScreen.screens.hashValue
            if self.preScreensHashValue != hashValue {
                self.preScreensHashValue = hashValue
                self.reloadWallpaperWindows()
            }
        }
        CFRunLoopAddObserver(CFRunLoopGetMain(), observer, .commonModes)
        
        /// - 监听界面改变
        NSWorkspace.shared.notificationCenter.addObserver(forName: NSWorkspace.activeSpaceDidChangeNotification, object: nil, queue: .main) { _ in
            self.wallpaperWindowDict.forEach({
                $0.value.orderFront(nil)
            })
        }
    }

    // MARK: - file fander
    func pickFile() -> URL? {
        let op = NSOpenPanel()
        op.canChooseFiles = false
        op.canChooseDirectories = true
        if op.runModal() == .OK {

            return op.urls.first
        }
        return nil
    }
    
    func showInFinder(url: URL?) {
        
        guard let url = url else {
            print(url)
            return }
        if url.isFileURL {
            NSWorkspace.shared.activateFileViewerSelecting([url])
        }
        else {
            NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: url.path)
        }
        
    }
    
    
    // MARK: - StatusItem
    var statusMenuItem: NSStatusItem!
    var muteItem:NSMenuItem!
    var colorItem:NSMenuItem!
    
    
    func createStatusMenuItem() {
        
        self.statusMenuItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        self.statusMenuItem.button?.title = "N0va"
        let menu = NSMenu()
        menu.addItem(.init(title: "在访达中打开game", action: #selector(statusMenuItemClick(_:)), keyEquivalent: ""))
        menu.addItem(.init(title: "在访达中打开color", action: #selector(statusMenuItemClick(_:)), keyEquivalent: ""))
        menu.addItem(.separator())
        if UserDefaults.standard.integer(forKey: "mute")==1 {
            self.muteItem = NSMenuItem(title: "取消静音", action: #selector(statusMenuItemClick(_:)), keyEquivalent: "")
        }else{
            self.muteItem = NSMenuItem(title: "静音", action: #selector(statusMenuItemClick(_:)), keyEquivalent: "")
        }
        menu.addItem(self.muteItem)
        menu.addItem(.separator())
        
        menu.addItem(.init(title: "使用教程", action: #selector(statusMenuItemClick(_:)), keyEquivalent: ""))
        
        menu.addItem(.separator())
        menu.addItem(.init(title: "退出", action: #selector(statusExitItemClick(_:)), keyEquivalent: "q"))
        
        self.statusMenuItem.menu = menu
        
        // url 是无效的,video 也是无效的
        self.model = WallpaperModel.init(type: .video, url: URL.init(string: "file:///User")!)
    }
    
    @objc func statusExitItemClick(_ item: NSMenuItem) {
        NSApp.terminate(nil)
    }
    
    @objc func statusMenuItemClick(_ item: NSMenuItem) {
//        guard let url = pickFile() else {
//            return
//        }
        
        switch item.title {
//        case "本地网页":
//            self.model = WallpaperModel.init(type: .web, url: url)
//            self.writeCache()
//
//        case "视频":
//            self.model = WallpaperModel.init(type: .video, url: url)
//            self.writeCache()
//
        case "在访达中打开game":
            
            let directoryPath = NSHomeDirectory() + "/Library/Application Support/N0va/game"
            do{
                try FileManager.default.createDirectory(atPath: directoryPath, withIntermediateDirectories: true, attributes: nil)
                
            }catch{
                print("Cannot create directory")
            }
            let urlwithPercentEscapes = directoryPath.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)
            let url = URL.init(string: urlwithPercentEscapes!)
            showInFinder(url:url)
            
            self.model = WallpaperModel.init(type: .video, url: url!)
            self.writeCache()
            
            
        case "在访达中打开color":
            
            let directoryPath = NSHomeDirectory() + "/Library/Application Support/N0va/color"
            do{
                try FileManager.default.createDirectory(atPath: directoryPath, withIntermediateDirectories: true, attributes: nil)
            }catch{
                print("Cannot create directory")
            }
            let urlwithPercentEscapes = directoryPath.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)
            let url = URL.init(string: urlwithPercentEscapes!)
            showInFinder(url:url)
            
            self.model = WallpaperModel.init(type: .video, url: url!)
            self.writeCache()
            
        case "静音":
            self.muteItem.title = "取消静音"
            UserDefaults.standard.setValue(1, forKey: "mute")
            UserDefaults.standard.synchronize()
           
            self.reloadWallpaperWindows()
            
        case "取消静音":
            self.muteItem.title = "静音"
            UserDefaults.standard.setValue(0, forKey: "mute")
            UserDefaults.standard.synchronize()
            
            self.reloadWallpaperWindows()
            
        case "使用教程":
            let url:URL?=URL.init(string: "https://github.com/balala8/N0va_for_mac.git")
            if NSWorkspace.shared.open(url!) {
                print("default browser was successfully opened")
            }

        default:
            break
        }
    }
    
    
    // MARK: - WallpaperWindow
    var wallpaperWindowDict = [AnyHashable: WallpaperWindow]()
    
    func reloadWallpaperWindows() {
        
        var releaseDict = self.wallpaperWindowDict
        let screens = NSScreen.screens
        for screen in screens {
            releaseDict.removeValue(forKey: screen.hashValue)

            var window = self.wallpaperWindowDict[screen.hashValue]
            if window == nil {
                window = WallpaperWindow(contentRect: .init(x: 0, y: 0, width: screen.frame.width, height: screen.frame.height), screen: screen)
                window?.reload(self.model)
                window?.backgroundColor = .clear
                window?.orderFront(nil)

                self.wallpaperWindowDict[screen] = window
            }
        }

        for (key, _) in releaseDict {
            self.wallpaperWindowDict.removeValue(forKey: key)?.orderOut(nil)
        }
    }
    
    // MARK: - Cache
    func writeCache() {
        
        guard let model = self.model else {
            return
        }
        
        UserDefaults.standard.setValue(model.encode(), forKey: kLastWallpaper)
        UserDefaults.standard.synchronize()
    }
    
    func reloadCache() {
        
        if let dict = UserDefaults.standard.object(forKey: kLastWallpaper) as? [String: Any] {
            let model = WallpaperModel(dict: dict)
            self.model = model
        }
        
    }
}
