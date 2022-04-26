//
//  GumletInsightsAVPlayerTests.swift
//  GumletInsightsAVPlayerTests
//

//


import XCTest
import AVKit
import AVFoundation
import CoreFoundation
import GumletInsightsAVPlayer

class GumletInsightsAVPlayerTests: XCTestCase {
    
    
    let playerCore = AVPlayerCore()
       let eventHandler = EventHandler()
   
       func test_setUpEvent()
       {
           
           var player = AVPlayer()
          
           let video_url = "https://video.gumlet.io/5f462c1561cf8a766464ffc4/614cae2b71ee9511b7069b55/1.m3u8"

           let videoURL = NSURL(string:video_url)
           player = AVPlayer(url: videoURL! as URL)
          
           
           playerCore.setupPlayer(playerAV:player, propertyId:"6Xlq31eG")
           
           
           let play_current_time = playerCore.getPlay_Pause_Time()
           let CurrentTimeBeforeEvent = Int(Date().timeIntervalSince1970 * 1000)
           eventHandler.callBufferingStart(currentState:"Play", playCurrentTime: play_current_time)


           let play_current_time_one = playerCore.getPlay_Pause_Time()
           eventHandler.callBufferingEnd(currentState: "Buffering", playCurrentTime: play_current_time_one)
           let CurrentTimeAfterEvent = Int(Date().timeIntervalSince1970 * 1000)
           let finalTime = abs(CurrentTimeBeforeEvent - CurrentTimeAfterEvent)
           let data = playerCore.getPreviousTime()
            
           XCTAssertLessThanOrEqual(finalTime, data, "eventName:\(finalTime)and\(String(describing: data))")
   //        XCTAssertGreaterThanOrEqual(finalTime, data, "eventName:\(finalTime)and\(String(describing: data))")
           
       }
       
       func test_assertPlayer_CallIds()
       {
           let expectedUserId = UIDevice.current.identifierForVendor!.uuidString
           let actualUserId = playerCore.createUniqueId()
           XCTAssertEqual(actualUserId, expectedUserId, "actualUserId:\(actualUserId)and\(expectedUserId)")
           
          
           let actualSessionId = playerCore.checkSessionId()
           XCTAssertNotNil(actualSessionId)
           
         
           let actualPlaybackId = playerCore.createPlayBackId()
           XCTAssertNotNil(actualPlaybackId)
           
           
           let actualEventId = playerCore.createEventId()
           XCTAssertNotNil(actualEventId)
           
           let actualPlayerInstanceId = playerCore.createPlayerInstanceId()
           XCTAssertNotNil(actualPlayerInstanceId)
       }
       
   }


//    override func setUpWithError() throws {
//        // Put setup code here. This method is called before the invocation of each test method in the class.
//    }
//
//    override func tearDownWithError() throws {
//        // Put teardown code here. This method is called after the invocation of each test method in the class.
//    }
//
//    func testExample() throws {
//        // This is an example of a functional test case.
//        // Use XCTAssert and related functions to verify your tests produce the correct results.
//    }
//
//    func testPerformanceExample() throws {
//        // This is an example of a performance test case.
//        measure {
//            // Put the code you want to measure the time of here.
//        }
//    }

}
