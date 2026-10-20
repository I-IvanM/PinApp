import SwiftUI

@main
struct PinAppApp: App {

    let dependencies: AppDependencies

    init() {
        dependencies = AppDependencies()
    }

    var body: some Scene {
        WindowGroup {
            AppView(dependencies: dependencies)
        }
    }
}
