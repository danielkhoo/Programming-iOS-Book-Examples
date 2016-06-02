

import UIKit

class Pep: UIViewController {
    
    var boy : String // * now assignable, we will assign on decode
    @IBOutlet var name : UILabel!
    @IBOutlet var pic : UIImageView!
    
    // we add "required" to satisfy the compiler's worry that class's "self" might be a subclass
    required init(pepBoy boy:String) {
        self.boy = boy
        super.init(nibName: "Pep", bundle: nil)
        self.restorationIdentifier = "pep" // *
        // self.restorationClass = self.dynamicType // * no restoration class, let app delegate point
    }
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    override func encodeRestorableState(with coder: NSCoder) {
        // super.encodeRestorableStateWithCoder(coder)
        print("pep about to encode boy \(self.boy)")
        coder.encode(self.boy, forKey:"boy")
    }
    
    // and now we simply decode directly
    
    override func decodeRestorableState(with coder: NSCoder) {
        // super.decodeRestorableStateWithCoder(coder)
        let boy : AnyObject? = coder.decodeObject(forKey:"boy")
        print("pep about to decode boy \(boy)")
        if let boy = boy as? String {
            self.boy = boy
        }
    }
    
    // one more step; in case we just did state restoration,
    // match interface to newly assigned boy
    // oops, not DRY: this is exactly the same as viewDidLoad()
    
    override func applicationFinishedRestoringState() {
        self.name.text = self.boy
        self.pic.image = UIImage(named:"\(self.boy.lowercased()).jpg")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.name.text = self.boy
        self.pic.image = UIImage(named:"\(self.boy.lowercased()).jpg")
    }
    
    override var description : String {
    return self.boy
    }
    
    @IBAction func tap (_ sender: UIGestureRecognizer?) {
        NSNotificationCenter.default().post(name: "tap", object: sender)
    }
}

// and no UIViewControllerRestoration

