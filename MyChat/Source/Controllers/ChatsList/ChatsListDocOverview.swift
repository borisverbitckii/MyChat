//
//  ChatsListDocOverview.swift
//  MyChat
//
//  Created by Boris Verbitsky on 05.04.2022.
//

/*

 Обзор модуля ChatsList

 Архитектура: MVVM

 Модуль собирается в ChatsListModuleBuilder

 Прокидываются зависимости во вьюмодель:
 - CoordinatorProtocol для координации и передачи данных

 Сам модуль состоит из:
 - ChatsListUIElements (отдельно вынесенные UI компоненты)
 - ChatsListViewController (контроллер)
 - ChatsListViewModel(вью модель), которая состоит из
  - input(все, что контроллер хочет от модели)
  - output(все, что выходит из модели в контроллер)

 */
