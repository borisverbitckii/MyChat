//
//  AgreementsModuleBuilder.swift
//  MyChat
//
//  Created by Boris Verbitsky on 19.07.2022.
//

import UIKit

final class AgreementsModuleBuilder {

    func build(type: AgreementsType) -> AgreementsViewController {
        let viewModel = AgreementsViewModel(type: type)
        let uiElements = AgreementsUI()
        let viewController = AgreementsViewController(viewModel: viewModel, uiElements: uiElements)
        return viewController
    }
}
