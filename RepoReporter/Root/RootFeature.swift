/// Copyright (c) 2021 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import ComposableArchitecture

struct RootState {
  var userState = UserState()
  var repositoryState = RepositoryState()
}

enum RootAction {
  case userAction(UserAction)
  case repositoryAction(RepositoryAction)
}

struct RootEnvironment { }

/*
 Composing Reducers
 The final step is to add repositoryReducer to rootReducer. Switch back to RootFeature.swift.
 But how can a reducer working on local state, actions and environment work on the larger, global state, actions and environment? TCA provides two methods to do so:
 combine: Creates a new reducer by combining many reducers. It executes each given reducer in the order they are listed.
 pullback: Transforms a given reducer so it can work on global state, actions and environment. It uses three methods, which you need to pass to pullback.
 */

// swiftlint:disable trailing_closure
let rootReducer = Reducer<
  RootState,
  RootAction,
  SystemEnvironment<RootEnvironment>
>.combine(
  userReducer.pullback(
    state: \.userState,
    action: /RootAction.userAction,
    environment: { _ in .live(environment: UserEnvironment(userRequest: userEffect)) }),
  // 1 pullback transforms repositoryReducer to work on RootState, RootAction and RootEnvironment.
  repositoryReducer.pullback(
    // 2 repositoryReducer works on the local RepositoryState. You use a a key path to plug out the local state from the global RootState.
    state: \.repositoryState,
    // 3 a case path makes the local RepositoryAction accessible from the global RootAction. Case paths come with TCA and are like key paths, but work on enumeration cases.
    action: /RootAction.repositoryAction,
    // 4
    environment: { _ in .live(environment: RepositoryEnvironment(repositoryRequest: repositoryEffect)) })
)
// swiftlint:enable trailing_closure
