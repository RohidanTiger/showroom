import UIKit
import OAuthSwift
import Nuke

final class DribbbleShotsViewController: UIViewController {
    
    fileprivate var networkingManager = NetworkingManager()
    
    @IBOutlet weak var collectionView: UICollectionView!
}

// MARK: Life Cycle
extension DribbbleShotsViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // customize nav bar
        title = "Dribbble Shots"
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneHandler))
        navigationItem.leftBarButtonItem = doneButton

        // customze collection
        collectionView.register(DribbbleShotCell.self)
        let margins = collectionView.layoutMargins.left + collectionView.layoutMargins.right
        let itemWidth = (UIScreen.main.bounds.size.width - margins) / 2 - 14
        (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.itemSize = CGSize(width: itemWidth, height: itemWidth)

        // fetch items
        networkingManager.fetchDribbbleShots()
            .map { $0.filter { shot in shot.animated } }
            .bind(to: collectionView.rx.items(cellIdentifier: "Shot", cellType: DribbbleShotCell.self)) { row, element, cell in
                cell.nameLabel.text = element.title
                if let url = element.imageUrl { Manager.shared.loadImage(with: url, into: cell.imageView) }
            }
            .disposed(by: rx.disposeBag)
        
        // selected item
        collectionView.rx
            .modelSelected(Shot.self)
            .subscribe(onNext: { shot in
                print(shot)
                
                let alertView = UIAlertController(title: "Do you want send this Shot", message: nil, preferredStyle: .alert)
                alertView.addAction(UIAlertAction(title: "OK", style: .cancel) { _ in
                })
                UIViewController.current?.present(alertView, animated: true, completion: nil)
            })
            .disposed(by: rx.disposeBag)
    }
    
    // MARK: Actions
    @objc func doneHandler() {
        dismiss(animated: true, completion: nil)
    }
}
