
import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
  
  @IBOutlet weak var mySearchTerm: UISearchBar!
  @IBOutlet weak var myResults: UITableView!
  
  let disposeBag = DisposeBag()
  var results : [WikipediaSearchResult]  = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
   
    let searchTerm: Observable<String> = self.mySearchTerm.rx.text.orEmpty
      .throttle(0.3, scheduler:MainScheduler.instance)
      .filter { $0.characters.count > 1 }
    
    
    searchTerm.flatMap { term in
        DefaultWikipediaAPI.sharedAPI
          .getSearchResults(term)
      }
      .subscribe(onNext: { r in
          self.results = r
        self.myResults.reloadData()
          print("results: \(r)")
      })
      .addDisposableTo(disposeBag)
    // Do any additional setup after loading the view, typically from a nib.
  }

  func numberOfSections(in:UITableView) -> Int { return 1 }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    print("results.count: \(self.results.count)")
    return self.results.count
  }
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "Cell")
    if cell == nil {
      cell = UITableViewCell(style: .subtitle, reuseIdentifier:"Cell")
    }
    let data = self.results[indexPath.row]
    cell.textLabel?.text = data.title
    cell.detailTextLabel?.text = data.description
    // TODO
    return cell
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let rowNumber = indexPath.row
    let item = self.results[rowNumber]
    print("You selected \(item)")
    UIApplication.shared.open(item.URL as! URL, options: [:], completionHandler: nil)
  }


  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }


}

