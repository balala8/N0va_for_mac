//
//  Application.swift
//  Wallpaper
//
//  Created by Plumk on 2021/4/25.
//

import Cocoa
import Zip

class Application: NSApplication {
    
    var desktopHandleWindowNumbers = Set<Int>()
    
    let appDelegate = AppDelegate()
    
    override func run() {

        if !UserDefaults.standard.bool(forKey: "unziped_game") {
            // 1. 定义一个 `NSAlert` 对象，可以使用 `Error` 也可以什么都不用直接定义
            let alert = NSAlert()

            // 2. 添加 `Alert` 的显示相关信息
            alert.messageText = "准备读取资源"
            alert.informativeText = "第一次运行，点击 ok 后开始读取 game 资源,可能会有几秒钟的卡顿"

            // 3. 执行显示即可
            alert.runModal()
            
            // 第一次运行，提取视频文件到 game 和 color
            do {
                let filePath = Bundle.main.url(forResource: "game", withExtension: "zip")!
    //            let documentsDirectory = FileManager.default.urls(for:.applicationDirectory, in: .userDomainMask)[0]
                let documentsDirectory = "file://" + NSHomeDirectory() + "/Library/Application Support/N0va/"
                let urlwithPercentEscapes = documentsDirectory.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)
                let url = URL.init(string: urlwithPercentEscapes!)
                print(documentsDirectory)
                try Zip.unzipFile(filePath, destination: url!, overwrite: true, password: "password", progress: { (progress) -> () in
                    print(progress)
                }) // Unzip
                UserDefaults.standard.setValue(true, forKey: "unziped_game")
            }
            catch {
              print("Something went wrong")
            }
        }
        if !UserDefaults.standard.bool(forKey: "unziped_color") {
            // 1. 定义一个 `NSAlert` 对象，可以使用 `Error` 也可以什么都不用直接定义
            let alert = NSAlert()

            // 2. 添加 `Alert` 的显示相关信息
            alert.messageText = "准备读取资源"
            alert.informativeText = "第一次运行，点击 ok 后开始读取 game 资源，可能会有几秒钟的卡顿"
            
            // 3. 执行显示即可
            alert.runModal()
            
            // 第一次运行，提取视频文件到 game 和 color
            do {
                let filePath = Bundle.main.url(forResource: "color", withExtension: "zip")!
    //            let documentsDirectory = FileManager.default.urls(for:.applicationDirectory, in: .userDomainMask)[0]
                let documentsDirectory = "file://" + NSHomeDirectory() + "/Library/Application Support/N0va/"
                let urlwithPercentEscapes = documentsDirectory.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)
                let url = URL.init(string: urlwithPercentEscapes!)
                print(documentsDirectory)
                try Zip.unzipFile(filePath, destination: url!, overwrite: true, password: "password", progress: { (progress) -> () in
                    print(progress)
                }) // Unzip
                UserDefaults.standard.setValue(true, forKey: "unziped_color")
            }catch {
              print("Something went wrong")
            }
        }
        self.delegate = self.appDelegate
        super.run()
    }
    
}

let App = NSApp as! Application
