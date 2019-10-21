# Project 1 - *Mooveeze*

**Mooveeze** is a movies app using the [The Movie Database API](http://docs.themoviedb.apiary.io/). { now https://developers.themoviedb.org/3 }

An app I wrote in 2016 to learn swift at Codepath camp. Was a simple MVC app.
I took a look at it recently and decided to update it to a MVVM pattern with unidirectional binding.
The view models contain 'dynamic' model wrappers which do the binding from views to fields. 
The view models also handle fetching and posting of data as well as state managment. 
Flow coordinators are used to off-load the view controllers from managing transitions
and having 'knowledge' about other view controllers. Flow coordinators also inject
the view models into their corresponding controllers. 

The view models don't really 'know' or care that they live inside of view controllers, 
which facilitates re-use and testing. For an example of this reusability, see the tableView data source 
implementation in MoviesViewController. The movie detail view model (MovieViewModel) 
is used to render summary information for the movie lists; the movie detail view model is also used 
more fully as the primary view model in MovieViewController. The same reuse pattern can be seen again in 
MovieVideoViewModel, where it is used to render the video summary cells in MovieViewController
in the the tableView data source implementation. MovieVideoViewModel is also
used as the primary view model in MovieVideoWebViewController, which plays the videos.

This test project also demonstrates a clean separation of concerns for sending and receiving remote data.
Multiple clients and transports (e.g. websocket, JSON-RPC) could be added using similar interfaces and layering.

for login Test 
user: emmaroomie
password: emmaroomie

note: Login VC can freeze when uitextfield becomes first responder due to an ios13 simulator bug.
On simulator, do Edit->Automatically Sync Pasteboard to deselect, followed by Hardware->Restart
see: https://forums.developer.apple.com/thread/122972

nb: ui is ugly

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

## Notes

Describe any challenges encountered while building the app.


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



