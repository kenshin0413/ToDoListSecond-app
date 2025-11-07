//
//  ListViewModelReference.swift
//  ToDoListSecond
//
//  Created by miyamotokenshin on R 7/11/07.
//

import Foundation

final class ListViewModelReference {
    static var shared: ListViewModelReference?
    weak var viewModel: ListViewModel?

    init(viewModel: ListViewModel) {
        self.viewModel = viewModel
        ListViewModelReference.shared = self
    }
}
