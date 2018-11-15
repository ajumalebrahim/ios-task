import UIKit
import RxSwift


/**
 The view controller responsible for listing all the campaigns. The corresponding view is the `CampaignListingView` and
 is configured in the storyboard (Main.storyboard).
 */
class CampaignListingViewController: UIViewController {

    let disposeBag = DisposeBag()

    @IBOutlet
    private(set) weak var typedView: CampaignListingView!

    override func viewDidLoad() {
        super.viewDidLoad()

        assert(typedView != nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Load the campaign list and display it as soon as it is available.
        let netService = ServiceLocator.instance.networkingService
        let campService = netService.createObservableResponse(request: CampaignListingRequest())
            campService.observeOn(MainScheduler.instance)
            .subscribe(
                onNext: { [weak self] campaigns in
                self?.typedView.display(campaigns: campaigns)
            },
                onError: { [weak self] error in
                    let alert = UIAlertController.init(title: "Error", message: "\(error.localizedDescription)", preferredStyle: .alert)
                    let tryAgain = UIAlertAction.init(title: "Try Again", style: .default, handler: { (action) in
                        campService.retry().observeOn(MainScheduler.instance).subscribe(onNext: {campaigns in
                            self?.typedView.display(campaigns: campaigns)
                        }).disposed(by: (self?.disposeBag)!)
                    })
                    alert.addAction(tryAgain)
                    self?.present(alert, animated: true, completion:nil)
            })
            .addDisposableTo(disposeBag)
    }
}
