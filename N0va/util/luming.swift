//
//  luming.swift
//  Wallpaper
//
//  Created by yongfang on 2022/4/22.
//

import Foundation

class LuMing{
    //状态枚举
    enum Status:Int{
        case start = 0
        case shrink
        case sitting
        case earphone
        case straighten
    }

    // 状态属性
    var status:Status = Status.start
    
    let game:String = "file://" + NSHomeDirectory() + "/Library/Application Support/N0va/game/"
    let color:String = "file://" +  NSHomeDirectory() + "/Library/Application Support/N0va/color/"
//    var quality:String = "2k/"
   
    var gameVideoArray:[String]?
    
    init() {

    }
    
    func getPathAllXmlFile(path:String) -> [String]{
        var fileNameArray:[String] = []
        var xmlFileArray:[String] = []
        do {
            fileNameArray = try FileManager.default.contentsOfDirectory(atPath: path)
            for fileName in fileNameArray {
                if fileName.hasSuffix(".mp4") {
                    let xmlFileName = fileName.prefix(fileName.count-4)
                    xmlFileArray.append(String(xmlFileName))
                }
            }
        } catch let error as NSError {
            print("get file path error: \(error)")
        }
        return xmlFileArray
    }
    
    private func get_name(path:String)->String
    {
        var filearray = getPathAllXmlFile(path: String(path.suffix(path.count-7)))
        if filearray.count==0 {
            return "1"
        }
        return filearray[Int(arc4random()) % filearray.count ]
    }
    
    @objc func get_net_url()->String
    {
        var url = ""
        
        // 1%的概率播放 game 视频
        if random_Bool(prop: 1) {
            let name = get_name(path:self.game)
            // game 文件夹为空，不播放 game
            if name=="1" {
                switch self.status {
                case Status.start:
                    url = stateStart()
                case Status.shrink:
                    url = stateShrink()
                case Status.sitting:
                    url = stateSitting()
                case Status.earphone:
                    url = stateEarphone()
                case Status.straighten:
                    url = stateStrainghten()
                }
                return url
            }
            
            url = self.game + get_name(path:self.game) + ".mp4"
            
            return url
        }
        
        switch self.status {
        case Status.start:
            url = stateStart()
        case Status.shrink:
            url = stateShrink()
        case Status.sitting:
            url = stateSitting()
        case Status.earphone:
            url = stateEarphone()
        case Status.straighten:
            url = stateStrainghten()
        }
        return url
    }
    
    @objc func random_Bool(prop:Int) ->Bool
    {
        if arc4random()%100 >= prop{
            return false
        }
        return true
    }

    @objc func stateStart()->String
    {
        // start 一共有三个视频
        print(self.color)
        let url = self.color + "start/" + get_name(path:self.color+"start/") + ".mp4"
        
        self.status = Status.sitting
        return url
    }
    
    @objc func stateShrink()->String
    {
        //shrink 能切换到 wake 或者继续 shrink,shrink 有1个视频
        var url = ""
        // 是否切换到 wake状态 10%的概率
        if random_Bool(prop: 5){
            // 切换到 wake(sitting) 状态
            url = self.color+"shrink2sitting.mp4"
            self.status = Status.sitting
        }else{
            // 不切换状态
            url = self.color + "shrink/" + get_name(path:self.color+"shrink/") + ".mp4"
            
            self.status = Status.shrink
        }
        return url
    }

    @objc func stateSitting()->String
    {
        //sitting 能切换到 earphone 和 straighten_sleep
        var url = ""
        // 是否切换到 earphone状态 5%的概率
        if random_Bool(prop: 6){
            // 切换到 earphone 状态
            url = self.color+"sitting2earphone.mp4"
            self.status = Status.earphone
            
        }else if random_Bool(prop: 7){
            // 切换到 straighten_sleep状态
            url = self.color+"sitting2straighten.mp4"
            self.status = Status.straighten
        }else{
            // 不切换状态 sitting 有5个坐姿
            url = self.color + "sitting/" + get_name(path:self.color+"sitting/") + ".mp4"
            self.status = Status.sitting
        }
        return url
    }

    @objc func stateEarphone()->String
    {
        var url=""
        // 是否切换到 sitting状态 10%的概率
        if random_Bool(prop: 5) {
            // 切换到 sitting 状态
            url = self.color+"earphone2sitting.mp4"
            self.status = Status.sitting
        }else{
            // 不切换状态 earphone 有两个姿势
            url = self.color + "earphone/" + get_name(path:self.color+"earphone/") + ".mp4"
            self.status = Status.earphone
        }
        return url
    }

    @objc func stateStrainghten()->String
    {
        //Strainghten 能切换到 shrink 或者 wake 或者 继续 straighten
        var url = ""
            // 是否切换到 shrink状态 5%的概率
            if random_Bool(prop: 5){
                // 切换到 shrink 状态
                url = self.color+"straighten2shrink.mp4"
                self.status = Status.shrink
            }else if random_Bool(prop: 6){
                // 切换到 wake状态 ，wake 就是 sitting
                url = self.color+"straighten2sitting.mp4"
                self.status = Status.sitting
            }else{
                // 不切换状态 straighten 有3个视频
                url = self.color + "straighten/" + get_name(path:self.color+"straighten/") + ".mp4"
                self.status = Status.straighten
            }
        return url
    }

}
