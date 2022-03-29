//
//  RegisterDocOverview.swift
//  MyChat
//
//  Created by Boris Verbitsky on 23.03.2022.
//

// Обзор модуля Register/Auth

// Архитектура: MVVM

// Модуль собирается в RegisterModuleBuilder
//  Прокидываются зависимости во вьюмодель:
// - CoordinatorProtocol для координации и передачи данных
// - AuthManagerProtocol для проверки авторизации

// Сам модуль состоит из:
// - RegisterUIElements (отдельно вынесенные UI компоненты)
// - RegisterViewController (контроллер)
// - RegisterViewModel(вьб модель)
