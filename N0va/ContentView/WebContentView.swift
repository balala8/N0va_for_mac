//
//  WebContentView.swift
//  Wallpaper
//
//  Created by Plumk on 2021/4/25.
//

import Cocoa
import WebKit

class WebContentView: ContentView {

    class WebView: WKWebView {
        override func draw(_ dirtyRect: NSRect) {
            super.draw(dirtyRect)
            NSColor.black.set()
            dirtyRect.fill()
        }
    }

    var webview: WKWebView?
    
    private var currentUrl: URL?
    private var mouseMonitor: Any?
    override func commInit() {
        super.commInit()
        
        // -- Event
        self.mouseMonitor = NSEvent.addGlobalMonitorForEvents(matching: [
            .mouseMoved, .leftMouseDown, .leftMouseUp
        ]) {[unowned self] (event) in
            guard let webview = self.webview, App.desktopHandleWindowNumbers.contains(event.windowNumber), let screen = self.window?.screen else {
                return
            }
            
            var point = event.locationInWindow
            point.y = screen.frame.maxY - point.y
            point.x = point.x - screen.frame.minX
            switch event.type {
            case .mouseMoved:
                webview.evaluateJavaScript("wallpaper_mouseMoveEvent(\(point.x), \(point.y))")
            case .leftMouseDown:
                webview.evaluateJavaScript("wallpaper_mouseDownEvent(\(point.x), \(point.y))")
            case .leftMouseUp:
                webview.evaluateJavaScript("wallpaper_mouseUpEvent(\(point.x), \(point.y))")
            default:
                break
            }
        }
        
    }
    
    func makeWebView(isLocalFile: Bool) {
        self.webview?.removeFromSuperview()
        self.webview = nil
        
        let conf = WKWebViewConfiguration()
        conf.preferences.javaScriptCanOpenWindowsAutomatically = false
        conf.allowsAirPlayForMediaPlayback = false
        conf.mediaTypesRequiringUserActionForPlayback = .all
        
        if isLocalFile {
            conf.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
            conf.setValue(true, forKey: "allowUniversalAccessFromFileURLs")
        }
        if let path = Bundle.main.path(forResource: "inject", ofType: "js"), let str = try? String.init(contentsOfFile: path) {
            conf.userContentController.addUserScript(.init(source: str, injectionTime: .atDocumentEnd, forMainFrameOnly: false))
        }
        
        let webview = WebView(frame: self.bounds, configuration: conf)
        
        webview.navigationDelegate = self
        webview.allowsBackForwardNavigationGestures = false
        webview.uiDelegate = self
        self.addSubview(webview)
        
//        webview.loadHTMLString("<!DOCTYPE html><html><head></head><body style='background-color: black'></body></html>", baseURL: nil)
        self.webview = webview
    }
    
    override func loadUrl(_ url: URL) {
        super.loadUrl(url)
        self.currentUrl = url
        if url.isFileURL {
            self.makeWebView(isLocalFile: true)
            let direcotry = url.deletingLastPathComponent().relativePath
            self.webview?.loadFileURL(url, allowingReadAccessTo: URL(fileURLWithPath: direcotry))
        } else {
            self.makeWebView(isLocalFile: false)
            self.webview?.load(.init(url: url))
        }
    }
    
    deinit {
        if let obj = self.mouseMonitor {
            NSEvent.removeMonitor(obj)
        }
    }
    
    override func layout() {
        super.layout()
        self.webview?.frame = self.bounds
    }
}

// MARK: - WKNavigationDelegate
extension WebContentView: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {

        guard navigationAction.navigationType == .other else {
            decisionHandler(.cancel)
            return
        }
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
    }
    
}

// MARK: - WKUIDelegate
extension WebContentView: WKUIDelegate {
    
}
