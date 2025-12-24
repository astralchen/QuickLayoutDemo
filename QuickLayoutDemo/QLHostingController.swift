import UIKit
import QuickLayout

/// A UIViewController that hosts QuickLayout content, similar to SwiftUI's UIHostingController
///
/// Usage:
/// ```swift
/// class MyViewController: QLHostingController {
///     override var body: Layout {
///         VStack {
///             titleLabel
///             subtitleLabel
///         }
///     }
/// }
/// ```
open class QLHostingController: UIViewController {

    // MARK: - Properties

    /// The container view that will hold our layout
    @QuickLayout
    final class ContainerView: UIView {
        weak var hostingController: QLHostingController?

        var body: Layout {
            hostingController?.body ?? EmptyLayout()
        }
    }

    private lazy var containerView: ContainerView = {
        let view = ContainerView()
        view.hostingController = self
        return view
    }()

    // MARK: - Layout Body

    /// Override this property to provide your layout
    /// This is similar to SwiftUI's body property
    open var body: Layout {
        EmptyLayout()
    }

    // MARK: - Lifecycle

    override open func loadView() {
        view = containerView
        view.backgroundColor = .systemBackground
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Layout Updates

    /// Call this method to trigger a layout rebuild when your state changes
    public func setNeedsLayoutUpdate() {
        containerView.setNeedsLayout()
    }

    /// Forces an immediate layout update
    public func layoutIfNeeded() {
        containerView.layoutIfNeeded()
    }
}

// MARK: - Convenience Extensions

extension QLHostingController {

    /// Creates a navigation controller with this hosting controller as root
    /// - Returns: A UINavigationController containing this controller
    public func wrappedInNavigationController() -> UINavigationController {
        return UINavigationController(rootViewController: self)
    }

    /// Sets the title of the hosting controller
    /// - Parameter title: The title to display
    /// - Returns: Self for method chaining
    @discardableResult
    public func withTitle(_ title: String?) -> Self {
        self.title = title
        return self
    }

    /// Sets the background color of the hosting controller's view
    /// - Parameter color: The background color
    /// - Returns: Self for method chaining
    @discardableResult
    public func withBackgroundColor(_ color: UIColor) -> Self {
        view.backgroundColor = color
        return self
    }
}

// MARK: - Alternative Approach: Composition-based Hosting Controller

/// A composition-based hosting controller that takes a layout in the initializer
/// Use this when you want to create layouts inline without subclassing
public final class QLComposableHostingController: UIViewController {

    @QuickLayout
    final class ContainerView: UIView {
        var layoutProvider: () -> Layout

        init(layoutProvider: @escaping () -> Layout) {
            self.layoutProvider = layoutProvider
            super.init(frame: .zero)
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        var body: Layout {
            layoutProvider()
        }
    }

    private let layoutProvider: () -> Layout
    private lazy var containerView: ContainerView = {
        ContainerView(layoutProvider: layoutProvider)
    }()

    // MARK: - Initialization

    /// Initialize with a layout builder closure
    /// - Parameter builder: Closure that returns the layout
    public init(@LayoutBuilder builder: @escaping () -> Layout) {
        self.layoutProvider = builder
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override public func loadView() {
        view = containerView
        view.backgroundColor = .systemBackground
    }

    // MARK: - Layout Management

    /// Rebuilds the layout
    public func setNeedsLayoutUpdate() {
        containerView.setNeedsLayout()
    }

    /// Forces an immediate layout update
    public func layoutIfNeeded() {
        containerView.layoutIfNeeded()
    }
}

// MARK: - Convenience Extensions for Composable Controller

extension QLComposableHostingController {

    /// Creates a navigation controller with this hosting controller as root
    public func wrappedInNavigationController() -> UINavigationController {
        return UINavigationController(rootViewController: self)
    }

    /// Sets the title
    @discardableResult
    public func withTitle(_ title: String?) -> Self {
        self.title = title
        return self
    }

    /// Sets the background color
    @discardableResult
    public func withBackgroundColor(_ color: UIColor) -> Self {
        view.backgroundColor = color
        return self
    }
}

// MARK: - Example Usage


 //Example 1: Subclass-based approach (similar to SwiftUI)

 class ProfileViewController: QLHostingController {

     let avatarImageView = UIImageView()
     let nameLabel = UILabel()
     let bioLabel = UILabel()

     let borderView = UIView()

     override func viewDidLoad() {
         super.viewDidLoad()

         // Configure views
         avatarImageView.image = UIImage(systemName: "apple.intelligence")
         avatarImageView.backgroundColor = .systemGray
         avatarImageView.layer.cornerRadius = 40
         avatarImageView.clipsToBounds = true

         borderView.layer.cornerRadius = 40
         borderView.layer.borderColor = UIColor.systemRed.cgColor
         borderView.layer.borderWidth = 4

         nameLabel.text = "John Doe"
         nameLabel.font = .systemFont(ofSize: 24, weight: .bold)

         bioLabel.text = "iOS Developer"
         bioLabel.textColor = .secondaryLabel
         bioLabel.numberOfLines = 0
     }

     override var body: Layout {
         VStack(alignment: .center, spacing: 16) {
             avatarImageView
                 .resizable()
                 .frame(width: 80, height: 80)
                 .overlay {
                     borderView
                 }

             nameLabel

             bioLabel
                 .padding(.horizontal, 20)
         }
         .padding(.all, 24)
     }
 }



 func makeDetailViewController(title: String, subtitle: String) -> UIViewController {

     let titleLabel = UILabel()
     titleLabel.text = title
     titleLabel.font = .systemFont(ofSize: 20, weight: .semibold)
     titleLabel.textAlignment = .center

     let subtitleLabel = UILabel()
     subtitleLabel.text = subtitle
     subtitleLabel.textColor = .secondaryLabel
     subtitleLabel.textAlignment = .center
     subtitleLabel.numberOfLines = 0

     let button = UIButton(type: .system)
     button.setTitle("Action", for: .normal)

     return QLComposableHostingController {
         VStack(alignment: .center, spacing: 20) {
             titleLabel
             subtitleLabel
             Spacer(40)
             button
         }
         .padding(.all, 24)
     }
     .withTitle("Details")
 }



 // Example 3: List-style layout

 class SettingsViewController: QLHostingController {

     let headerLabel = UILabel()
     let option1Switch = UISwitch()
     let option2Switch = UISwitch()
     let option3Switch = UISwitch()

     override func viewDidLoad() {
         super.viewDidLoad()
         title = "Settings"

         headerLabel.text = "Preferences"
         headerLabel.font = .systemFont(ofSize: 16, weight: .medium)
         headerLabel.textColor = .secondaryLabel
     }

     override var body: Layout {

         VStack(alignment: .leading, spacing: 0) {

             headerLabel
                 .padding(.horizontal, 16)
                 .padding(.vertical, 12)

             makeSettingRow(title: "Enable Notifications", control: option1Switch)
             makeDivider()

             makeSettingRow(title: "Dark Mode", control: option2Switch)
             makeDivider()

             makeSettingRow(title: "Auto-sync", control: option3Switch)

             Spacer()
         }
         .padding(.top, view.safeAreaInsets.top)
     }

     private func makeSettingRow(title: String, control: UISwitch) -> Layout {
         let label = UILabel()
         label.text = title

         return HStack {
             label
             Spacer()
             control
         }
         .padding(.horizontal, 16)
         .padding(.vertical, 12)
     }

     private func makeDivider() -> Layout {
         let divider = UIView()
         divider.backgroundColor = .separator

         return divider
             .frame(height: 1)
             .padding(.leading, 16)
     }
 }



// Example 4: Complex nested layout

 class DashboardViewController: QLHostingController {

     let profileImageView = UIImageView()
     let nameLabel = UILabel()
     let scoreLabel = UILabel()
     let achievementLabel = UILabel()
     let statsView1 = UIView()
     let statsView2 = UIView()
     let statsView3 = UIView()

     override func viewDidLoad() {
         super.viewDidLoad()

         // Configure views
         profileImageView.backgroundColor = .systemBlue
         profileImageView.layer.cornerRadius = 25
         profileImageView.clipsToBounds = true

         nameLabel.text = "Jane Smith"
         nameLabel.font = .systemFont(ofSize: 18, weight: .semibold)

         scoreLabel.text = "Score: 1250"
         scoreLabel.font = .systemFont(ofSize: 14)

         achievementLabel.text = "🏆 Top Performer"
         achievementLabel.font = .systemFont(ofSize: 12)

         [statsView1, statsView2, statsView3].forEach {
             $0.backgroundColor = .systemGray6
             $0.layer.cornerRadius = 8
         }
     }

     override var body: Layout {
         VStack(spacing: 24) {
             // Header Card
             HStack(spacing: 12) {
                 profileImageView
                     .frame(width: 50, height: 50)

                 VStack(alignment: .leading, spacing: 4) {
                     nameLabel
                     scoreLabel
                     achievementLabel
                 }

                 Spacer()
             }
             .padding(.all, 16)
             .background {
                 makeCardBackground()
             }

             // Stats Grid
             HStack(spacing: 12) {
                 statsView1
                     .frame(height: 100)
                 statsView2
                     .frame(height: 100)
                 statsView3
                     .frame(height: 100)
             }

             Spacer()
         }
         .padding(.all, 16)
         .padding(.top, view.safeAreaInsets.top)
     }

     private func makeCardBackground() -> UIView {
         let background = UIView()
         background.backgroundColor = .systemBackground
         background.layer.cornerRadius = 12
         background.layer.shadowColor = UIColor.black.cgColor
         background.layer.shadowOpacity = 0.1
         background.layer.shadowRadius = 8
         background.layer.shadowOffset = CGSize(width: 0, height: 2)
         return background
     }
 }



// Example 5: Dynamic content with state updates

 class CounterViewController: QLHostingController {

     private var count = 0 {
         didSet {
             updateLabels()
             setNeedsLayoutUpdate()
         }
     }

     let counterLabel = UILabel()
     let incrementButton = UIButton(type: .system)
     let decrementButton = UIButton(type: .system)

     override func viewDidLoad() {
         super.viewDidLoad()

         counterLabel.font = .systemFont(ofSize: 48, weight: .bold)
         counterLabel.textAlignment = .center

         incrementButton.setTitle("Increment", for: .normal)
         incrementButton.addTarget(self, action: #selector(increment), for: .touchUpInside)

         decrementButton.setTitle("Decrement", for: .normal)
         decrementButton.addTarget(self, action: #selector(decrement), for: .touchUpInside)

         updateLabels()
     }

     override var body: Layout {
         VStack(alignment: .center, spacing: 32) {
             Spacer()

             counterLabel

             HStack(spacing: 16) {
                 decrementButton
                 incrementButton
             }

             Spacer()
         }
         .padding(.all, 24)
     }

     @objc private func increment() {
         count += 1
     }

     @objc private func decrement() {
         count -= 1
     }

     private func updateLabels() {
         counterLabel.text = "\(count)"
     }
 }




#Preview("Profile") {
    ProfileViewController()
}


#Preview("Composable") {

    makeDetailViewController(
       title: "Welcome",
       subtitle: "This is a detailed description of the content"
   )


}


#Preview("Settings") {
    SettingsViewController()
}

#Preview("Dashboard") {
    DashboardViewController()
}

#Preview("Counter") {
    CounterViewController()
}



