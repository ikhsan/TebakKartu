import UIKit
import AVFoundation

class ViewController: UIViewController {
  
  var listKartu = [
    "A", "B", "C", "D", "E", "F",
    "A", "B", "C", "D", "E", "F",
  ]
  
  let petaGambar = [
    "A" : "coin",
    "B" : "flower",
    "C" : "powerup",
    "D" : "shroom",
    "E" : "shroom2",
    "F" : "star",
  ]
  
  var tebakanPertama: Int? = nil
  var audioPlayer: AVAudioPlayer? = nil
  
  enum SoundFx: String {
    case flip, match, win
  }
  
  func play(soundFx: SoundFx) {
    let asset = NSDataAsset(name: soundFx.rawValue)!
    let audioData = asset.data
    
    audioPlayer = try? AVAudioPlayer(data: audioData)
    audioPlayer?.volume = 1.0
    audioPlayer?.play()
  }

  @IBAction func tekanButton(_ sender: UIButton) {
    if sender.isSelected { return }
    
    let index = sender.tag
    bukaTutupKartu(kartu: sender)
    
    if let tebakanPertama = self.tebakanPertama {
      // tebakan kedua
      let tebakKartu1 = self.listKartu[tebakanPertama - 1]
      let tebakKartu2 = self.listKartu[index - 1]
      
      if tebakKartu1 == tebakKartu2 {
        // cocok
        play(soundFx: .match)
        cekMenang()
      } else {
        // ga cocok
        let kartuPertama = self.view.viewWithTag(tebakanPertama) as! UIButton
        
        // kasi jeda
        self.view.isUserInteractionEnabled = false
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5, execute: {
          [unowned self] in
          self.bukaTutupKartu(kartu: kartuPertama)
          self.bukaTutupKartu(kartu: sender)
          
          self.view.isUserInteractionEnabled = true
        })
      }
      
      self.tebakanPertama = nil
    } else {
      // tebakan pertama
      self.tebakanPertama = index
    }
  }
  
  func bukaTutupKartu(kartu: UIButton) {
    let gambar: UIImage
    let transisi: UIView.AnimationTransition
    
    if kartu.isSelected {
      gambar = UIImage(named: "deck")!
      transisi = .flipFromLeft
    } else {
      let isiKartu = listKartu[kartu.tag - 1]
      let namaGambar = petaGambar[isiKartu]!
      gambar = UIImage(named: namaGambar)!
      transisi = .flipFromRight
    }
    
    UIView.beginAnimations(nil, context: nil)
    UIView.setAnimationTransition(transisi, for: kartu, cache: false)
    kartu.setImage(gambar, for: .normal)
    kartu.isSelected.toggle()
    UIView.commitAnimations()
    
    play(soundFx: .flip)
  }
  
  func cekMenang() {
    let semuaKartu = self.view.subviews
      .filter { $0.tag > 0 }
      .compactMap { $0 as? UIButton }
    
    let menang = semuaKartu.allSatisfy { $0.isSelected }
    
    if menang {
      play(soundFx: .win)
      
      DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5, execute: {
        [unowned self] in
        
        semuaKartu.forEach { self.bukaTutupKartu(kartu: $0) }
        self.listKartu.shuffle()
        self.tebakanPertama = nil
      })
      
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    listKartu.shuffle()
  }

}

