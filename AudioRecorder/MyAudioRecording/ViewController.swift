//
//  ViewController.swift
//  MyAudioRecording
//
//  Created by Egemen Çığ on 29.06.2020.
//  Copyright © 2020 Egemen Çığ. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVAudioRecorderDelegate, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var buttonLabel: UIButton!
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var myLabel: UILabel!


    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVPlayer!
    
    var numberOfRecords:Int = 0
    
    var ourTimer = Timer()
    var timerDisplayed = 0
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            try AVAudioSession.sharedInstance().overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
           } catch _ {
        }
        self.myTableView.separatorStyle = .none
        
        if let number:Int = UserDefaults.standard.object(forKey: "myNumber") as? Int
        {
            numberOfRecords = number
        }
        
        
        AVAudioSession.sharedInstance().requestRecordPermission { (hasPermission) in
            
            if hasPermission {
                print("ACCEPTED")
            }
            
        }
        timeLabel.text = String(timerDisplayed)
    }
    
    @IBAction func record(_ sender: Any) {
        
        if audioRecorder == nil {
            numberOfRecords += 1
            let fileName = getDirectory().appendingPathComponent("\(numberOfRecords).m4a")
            
            let settings = [AVFormatIDKey: Int(kAudioFormatMPEG4AAC), AVSampleRateKey: 1200, AVNumberOfChannelsKey: 1, AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue]
            
            do {
                ourTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(action), userInfo: nil, repeats: true)
                audioRecorder = try AVAudioRecorder(url: fileName, settings: settings)
                audioRecorder.delegate = self
                audioRecorder.record()

                
                
                buttonLabel.setImage(UIImage(named: "stopicon"), for: .normal)
                myLabel.text = "Stop Recording"

            }
            catch {
                displayAlert(tittle: "Ups!", message: "Recording Failed")
            }
        }
        else {
            audioRecorder.stop()
            audioRecorder = nil
            ourTimer.invalidate()
            timerDisplayed = 0
            timeLabel.text = "0"
            UserDefaults.standard.set(numberOfRecords, forKey: "myNumber")
            myTableView.reloadData()
            myLabel.text = "Start Recording"
            buttonLabel.setImage(UIImage(named: "starticon"), for: .normal)
        }
        
    }
    
    @objc func action() {
        timerDisplayed += 1
        timeLabel.text = String(timerDisplayed)
    }
    
    func getDirectory() -> URL {
        
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = paths[0]
        return documentDirectory
        
    }
    
    func displayAlert(tittle: String, message:String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "dissmis", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfRecords
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = String(indexPath.row + 1)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let path = getDirectory().appendingPathComponent("\(indexPath.row + 1).m4a")
        
        do {
            audioPlayer =  AVPlayer(url: path)
            audioPlayer.volume = 10.0
            audioPlayer.play()
        }
        catch {
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        tableView.deleteRows(at: [indexPath], with: .automatic)
                
    }


}

