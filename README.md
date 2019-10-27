# Project 1 - *Mooveeze*

Hi. Here is an iOS test app I wrote in 2016 to learn swift at Codepath camp. It started out as a simple MVC app. It uses The Movie Database API (https://developers.themoviedb.org/3) to display movie metadata and play video previews.

I took a look at it recently and decided to update it to a simple MVVM pattern with unidirectional binding. The view models contain 'dynamic' model wrappers that do the binding from views to data fields. The view models also handle fetching and posting to The Movie Database API as well as state management. Flow coordinators are used to off-load the view controllers from managing transitions and having 'knowledge' about other view controllers. Flow coordinators also inject the view models directly into their corresponding controllers. 

The view models don't really 'know' or care that they live inside of view controllers, 
which facilitates re-use and testing. For an example of this reusability, see the tableView data source implementation in MoviesViewController. The movie detail view model (MovieViewModel) is used to render summary information for the movie lists; the movie detail view model is also used more fully as the primary view model in MovieViewController. The same reuse pattern can be seen again in MovieVideoViewModel, where it is used to render the video summary cells in MovieViewController in the the tableView data source implementation. MovieVideoViewModel is also used as the primary view model in MovieVideoWebViewController, which plays the videos.

This test project also demonstrates a clean separation of concerns for sending and receiving remote data. Multiple clients and transports (e.g. websocket, JSON-RPC) could be added using similar interfaces and layering. See the MVVM branch in the current repo for examples of running the app with two websocket implementations. The key idea to this approach is to cluster retrieval, create and delete calls into services based around model objects. There are two such models (UserAccount and Movie) and two Remote Services that allow the app to fetch and modify movie model and user model objects. Behind the scenes, the RemoteServices delegate their functionality to RemoteRequests. At a certain point in the class hierarchy, the RemoteRequest will call the main NetworkPlatform to forward the request to the RemoteClient resposible for sending and receiving the data based on a transport protocol, in this case restful json over HTTP. The RemoteClient will then build a URLRequest with the server url and other authentication goodies and send the URLRequest via its RemoteTransport. Clients are defined in a plist array in Network.plist. Switching build environments is quite simple using this approach, we just switch on Swift ‘preprocessor’-like #if/#else statements, and load the correct plist for our build environment. RemoteRequests are also mapped to clients in Network.plist, allowing for a flexible run-time lookup.

For login/logout testing, here is a test user:
user: emmaroomie
password: emmaroomie

note: Login VC can freeze when uitextfield becomes first responder due to an ios13 simulator bug. On the simulator, do Edit->Automatically Sync Pasteboard to deselect, followed by Hardware->Restart
see: https://forums.developer.apple.com/thread/122972

nb: The UI is primitive.

## User Stories

The following **required** functionality is completed:

- [x] User can view a list of movies currently playing in theaters. Poster images load asynchronously.
- [x] User can view movie details by tapping on a cell.
- [x] User sees loading state while waiting for the API.
- [x] User sees an error message when there is a network error.
- [x] User can pull to refresh the movie list.

The following **optional** features are implemented:

- [x] Add a tab bar for **Now Playing** and **Top Rated** movies.
- [ ] Implement segmented control to switch between list view and grid view.
- [x] Add a search bar.
- [x] All images fade in.
- [ ] For the large poster, load the low-res image first, switch to high-res when complete.
- [x] Customize the highlight and selection effect of the cell.
- [x] Customize the navigation bar.

The following **additional** features are implemented:

- [x] Shows movie genre and runtime via json fetch by movie
- [x] Infinite scrolling in movie lists
- [x] Login/Logout existing TMDb users.

## References

- [Binding](http://five.agency/solving-the-binding-problem-with-swift/)
- [MVVM](https://medium.com/flawless-app-stories/how-to-use-a-model-view-viewmodel-architecture-for-ios-46963c67be1b)
- [Flow Controllers](http://merowing.info/2016/01/improve-your-ios-architecture-with-flowcontrollers/)

## License

    Copyright [2019] [Bill Luoma]

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.



