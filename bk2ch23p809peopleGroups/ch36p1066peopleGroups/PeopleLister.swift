

import UIKit

class PeopleLister: UITableViewController, UITextFieldDelegate {
    
    let fileURL : NSURL
    var doc : PeopleDocument!
    var people : [Person] { // front end for the document's model object
        get {
            return self.doc.people
        }
        set (val) {
            self.doc.people = val
        }
    }

    init(fileURL:NSURL) {
        self.fileURL = fileURL
        super.init(nibName: "PeopleLister", bundle: nil)
    }
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = (self.fileURL.lastPathComponent! as NSString).deletingPathExtension
        let b = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(doAdd))
        self.navigationItem.rightBarButtonItems = [b]
        
        self.tableView.register(UINib(nibName: "PersonCell", bundle: nil), forCellReuseIdentifier: "Person")
        
        let fm = NSFileManager()
        self.doc = PeopleDocument(fileURL:self.fileURL)
        
        func listPeople(success:Bool) {
            if success {
                // self.people = self.doc.people as NSArray as [Person]
                self.tableView.reloadData()
            }
        }
        if !fm.fileExists(atPath:self.fileURL.path!) {
            self.doc.save(to:self.doc.fileURL,
                for: .forCreating,
                completionHandler: listPeople)
        } else {
            self.doc.open(completionHandler:listPeople)
        }
    }
    
    func doAdd (_ sender:AnyObject) {
        self.tableView.endEditing(true)
        let newP = Person(firstName: "", lastName: "")
        self.people.append(newP)
        let ct = self.people.count
        let ix = NSIndexPath(forRow:ct-1, inSection:0)
        self.tableView.reloadData()
        self.tableView.scrollToRow(at:ix, at:.bottom, animated:true)
        let cell = self.tableView.cellForRow(at:ix)!
        let tf = cell.withTag(1) as! UITextField
        tf.becomeFirstResponder()
        
        self.doc.updateChangeCount(.done)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if self.doc == nil {
            print("doc was nil")
            return 0
        }
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("self.people was \(self.people)")
        return self.people.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"Person", for: indexPath)
        let first = cell.withTag(1) as! UITextField
        let last = cell.withTag(2) as! UITextField
        let p = self.people[indexPath.row]
        first.text = p.firstName
        last.text = p.lastName
        first.delegate = self
        last.delegate = self
        return cell
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("did end editing")
        var v = textField.superview!
        while !(v is UITableViewCell) {v = v.superview!}
        let cell = v as! UITableViewCell
        let ip = self.tableView.indexPath(for:cell)!
        let row = ip.row
        let p = self.people[row]
        p.setValue(textField.text!, forKey: textField.tag == 1 ? "firstName" : "lastName")
        
        self.doc.updateChangeCount(.done)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: NSIndexPath) {
        self.tableView.endEditing(true)
        self.people.remove(at:indexPath.row)
        tableView.deleteRows(at:[indexPath], with:.automatic)
        
        self.doc.updateChangeCount(.done)
    }
    
    func forceSave(_:AnyObject?) {
        print("force save")
        self.tableView.endEditing(true)
        self.doc.save(to:self.doc.fileURL, for:.forOverwriting, completionHandler:nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NSNotificationCenter.default().addObserver(self, selector: #selector(forceSave), name: UIApplicationDidEnterBackgroundNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.forceSave(nil)
        NSNotificationCenter.default().removeObserver(self)
    }
    
    deinit {
        NSNotificationCenter.default().removeObserver(self)
    }

}
