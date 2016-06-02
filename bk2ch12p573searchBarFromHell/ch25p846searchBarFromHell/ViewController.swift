

import UIKit

func imageFromContextOfSize(_ size:CGSize, closure:() -> ()) -> UIImage {
    UIGraphicsBeginImageContextWithOptions(size, false, 0)
    closure()
    let result = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()
    return result
}

func lend<T where T:NSObject> (closure:(T)->()) -> T {
    let orig = T()
    closure(orig)
    return orig
}

extension CGRect {
    init(_ x:CGFloat, _ y:CGFloat, _ w:CGFloat, _ h:CGFloat) {
        self.init(x:x, y:y, width:w, height:h)
    }
}
extension CGSize {
    init(_ width:CGFloat, _ height:CGFloat) {
        self.init(width:width, height:height)
    }
}
extension CGPoint {
    init(_ x:CGFloat, _ y:CGFloat) {
        self.init(x:x, y:y)
    }
}
extension CGVector {
    init (_ dx:CGFloat, _ dy:CGFloat) {
        self.init(dx:dx, dy:dy)
    }
}



class ViewController: UIViewController {
    
    @IBOutlet var sb : UISearchBar!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sb.enablesReturnKeyAutomatically = false // true by default, even though unchecked!

        self.sb.searchBarStyle = .default
        self.sb.barStyle = .default
        self.sb.isTranslucent = true
        self.sb.barTintColor = UIColor.green() // unseen in this example
        // self.sb.backgroundColor = UIColor.red()
        
        let lin = UIImage(named:"linen.png")!
        let linim = lin.resizableImage(withCapInsets:UIEdgeInsetsMake(1,1,1,1), resizingMode:.stretch)
        self.sb.setBackgroundImage(linim, for:.any, barMetrics:.default)
        self.sb.setBackgroundImage(linim, for:.any, barMetrics:.defaultPrompt)
        
        let sepim = imageFromContextOfSize(CGSize(320,20)) {
            UIBezierPath(roundedRect:CGRect(5,0,320-5*2,20), cornerRadius:8).addClip()
            UIImage(named:"sepia.jpg")!.draw(in:CGRect(0,0,320,20))
        }
        self.sb.setSearchFieldBackgroundImage(sepim, for:[])
        // just to show what it does:
        self.sb.searchFieldBackgroundPositionAdjustment = UIOffsetMake(0, -10) // up from center
        
        // how to reach in and grab the text field
        for v in self.sb.subviews[0].subviews {
            if let tf = v as? UITextField {
                print("got that puppy")
                tf.textColor = UIColor.white()
                // tf.enabled = false
                break
            }
        }
        
        self.sb.text = "Search me!"
        //self.sb.placeholder = "Search me!"
        //    self.sb.showsBookmarkButton = true
        //    self.sb.showsSearchResultsButton = true
        //    self.sb.searchResultsButtonSelected = true
        
        let manny = UIImage(named:"manny.jpg")!
        self.sb.setImage(manny, for:.search, state:[])
        let mannyim = imageFromContextOfSize(CGSize(20,20)) {
            manny.draw(in:CGRect(0,0,20,20))
        }
        self.sb.setImage(mannyim, for:.clear, state:[])
        
        let moe = UIImage(named:"moe.jpg")!
        let moeim = imageFromContextOfSize(CGSize(20,20)) {
            moe.draw(in:CGRect(0,0,20,20))
        }
        self.sb.setImage(moeim, for:.clear, state:.highlighted)
        
        self.sb.showsScopeBar = true
        self.sb.scopeButtonTitles = ["Manny", "Moe", "Jack"]
        
        self.sb.scopeBarBackgroundImage = UIImage(named:"sepia.jpg")
        
        self.sb.setScopeBarButtonBackgroundImage(linim, for:[])

        let divim = imageFromContextOfSize(CGSize(2,2)) {
            UIColor.white().setFill()
            UIBezierPath(rect:CGRect(0,0,2,2)).fill()
        }
        self.sb.setScopeBarButtonDividerImage(divim,
            forLeftSegmentState:[], rightSegmentState:[])

        let atts : [String : AnyObject] = [
            NSFontAttributeName: UIFont(name:"GillSans-Bold", size:16)!,
            NSForegroundColorAttributeName: UIColor.white(),
            NSShadowAttributeName: lend {
                (shad:NSShadow) in
                shad.shadowColor = UIColor.gray()
                shad.shadowOffset = CGSize(2,2)
            },
            NSUnderlineStyleAttributeName: NSUnderlineStyle.styleDouble.rawValue
        ]
        self.sb.setScopeBarButtonTitleTextAttributes(atts, for:[])
        self.sb.setScopeBarButtonTitleTextAttributes(atts, for:.selected)
        
    }
}

extension ViewController : UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
