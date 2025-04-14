# Kite News (stack_wealth_news)

Kite News is a Flutter application designed to fetch and display news articles from the NewsAPI. It allows users to browse news by category, search for specific topics, view article details, and see their recent searches.

## Features

*   **Categorized News:** Browse news articles across various categories (General, Technology, Sports, Health, Business, Entertainment) using swipeable tabs.
*   **State Preservation:** Each news category tab maintains its own scroll position and loaded articles when switching between tabs.
*   **News Search:** Search for articles based on keywords.
*   **Recent Searches:** View and re-run recent search queries. Ability to clear recent search history.
*   **Article Details:** View the full news article content within an in-app WebView.
*   **Image Caching:** Efficiently loads and caches network images using `cached_network_image`.
*   **Loading Indicators:** Displays shimmer loading effects while fetching data.
*   **Error Handling:** Provides user feedback for network errors, API errors, and empty states.
*   **Pagination:** Implements infinite scrolling for news lists (both category and search results).


## Tech Stack & Key Dependencies

*   **Framework:** Flutter (SDK: ^3.7.2)
*   **Language:** Dart
*   **State Management:** `flutter_bloc` / `bloc` (v9+)
*   **Dependency Injection:** `get_it`
*   **Navigation:** `go_router`
*   **Networking:** `http`
*   **Local Storage:** `shared_preferences` (for recent searches)
*   **API:** NewsAPI (via `newsapi.org`)
*   **UI Helpers:**
    *   `cached_network_image` (Image loading/caching)
    *   `shimmer` (Loading animations)
    *   `webview_flutter` (Displaying article content)
    *   `equatable` (Value equality for Bloc states/events)
    *   `dartz` (Functional programming - Either for error handling)
    *   `intl` (Date formatting)
*   **Configuration:** `flutter_dotenv` (API Key Management)
*   **Linting:** `flutter_lints`
*   **Launcher Icons:** `flutter_launcher_icons`

## Architecture Overview

The application aims to follow Clean Architecture principles, separating concerns into distinct layers:

1.  **Presentation Layer:** Contains UI (Widgets/Screens), State Management (Blocs), and Navigation (GoRouter). It interacts with the Domain layer via Use Cases.
    *   Screens: `NewsScreen`, `SearchScreen`, `NewsDetailScreen`, `CategoryNewsList`.
    *   Blocs: `NewsSearchBloc` (handles fetching/pagination for categories and search), `CachedSearchBloc` (manages recent search history).
    *   Widgets: Reusable UI components like `NewsListItemWidget`, `NewsListItemShimmer`.
2.  **Domain Layer:** Contains business logic, entities, abstract repository definitions, and use cases. It is independent of UI and data sources.
    *   Entities: `ArticleEntity`, `SourceEntity`.
    *   Repositories (Abstract): `NewsRepository`.
    *   Use Cases: `GetNews`, `GetCachedSearchTerms`, `CacheSearchTerm`, `ClearCachedSearchTerms`.
3.  **Data Layer:** Responsible for fetching data from remote (API) and local (SharedPreferences) sources. Implements the repository interfaces defined in the Domain layer.
    *   Data Sources: `NewsRemoteDataSource` (fetches from NewsAPI), `NewsLocalDataSource` (manages cached searches).
    *   Repositories (Implementation): `NewsRepositoryImpl`.
    *   Models: `ArticleModel`, `SourceModel` (extend Domain entities, include parsing logic).

**Dependency Injection (`get_it`)** is used to provide instances of repositories, data sources, use cases, and Blocs throughout the application, promoting loose coupling.

## Setup Instructions

Follow these steps to set up and run the project locally:

1.  **Prerequisites:**
    *   Ensure you have the Flutter SDK (version matching `environment: sdk: ^3.7.2` or compatible) installed. See [Flutter installation guide](https://docs.flutter.dev/get-started/install).
    *   An IDE like VS Code or Android Studio with Flutter/Dart plugins installed.
    *   A NewsAPI key. You can get one for free from [newsapi.org](https://newsapi.org/).

2.  **Clone the Repository:**
    ```bash
    git clone <your-repository-url>
    cd stack_wealth_news
    ```

3.  **Create `.env` File:**
    *   In the root directory of the project, create a file named `.env`.
    *   Add your NewsAPI key to this file:
        ```env
        NEWS_API_KEY=YOUR_ACTUAL_API_KEY
        ```
    *   Replace `YOUR_ACTUAL_API_KEY` with the key you obtained from NewsAPI. The application includes a check (`AppConstants.validateApiKey`) that will log an error during startup if the key is missing, although the app might still run with limited functionality depending on error handling.

4.  **Install Dependencies:**
    ```bash
    flutter pub get
    ```

5.  **Generate Launcher Icons (Optional):**
    If you want to generate the app launcher icons based on the configuration in `pubspec.yaml`:
    ```bash
    flutter pub run flutter_launcher_icons
    ```

## Running the App

1.  **Ensure a device or simulator is running.**
2.  **Run the application:**
    ```bash
    flutter run
    ```
    Or use the "Run" command in your IDE.

## Key Design Decisions

*   **Clean Architecture:** Chosen to separate concerns, improve testability, and make the codebase easier to maintain and scale.
*   **BLoC for State Management:** Provides a robust and predictable way to manage application state, especially for features involving asynchronous operations (API calls) and complex UI logic (search, pagination, tabs). Multiple `NewsSearchBloc` instances are used in `NewsScreen` to manage the state of each category tab independently. A separate instance is used for the dedicated `SearchScreen`.
*   **GetIt for Dependency Injection:** A simple and efficient service locator pattern used to decouple dependencies between layers.
*   **GoRouter for Navigation:** Offers type-safe routing, declarative configuration, deep linking capabilities (though not fully utilized here), and easier handling of parameters and transitions. Custom slide transitions were implemented for a smoother feel.
*   **Repository Pattern:** Abstracts data fetching logic, allowing the Domain and Presentation layers to be independent of specific data sources (API vs. local cache).
*   **Functional Error Handling (`dartz`):** Using `Either<Failure, Success>` helps manage errors explicitly and avoid widespread try-catch blocks, leading to more predictable code flow. Custom `Failure` classes provide context about the error type.
*   **`.env` for API Key:** Keeps sensitive information like the API key out of version control.
*   **SharedPreferences for Recent Searches:** A simple solution for persisting a small amount of non-critical data locally.
*   **In-App WebView:** Chosen for viewing article details to keep the user within the app context, providing a more seamless experience than launching an external browser.

## Challenges Faced & Solutions

*   **Maintaining State Across Tabs (`NewsScreen`):** The initial approach might have used a single Bloc, leading to state being overwritten when switching tabs.
    *   **Solution:** Implemented multiple instances of `NewsSearchBloc` (one per category), managed by the `NewsScreen`'s state. Each category's list (`CategoryNewsList`) uses `BlocProvider.value` to get its dedicated Bloc and `AutomaticKeepAliveClientMixin` with `PageStorageKey` to preserve its state (including scroll position and data) when inactive.
*   **Search Screen UI Logic:** Determining the best way to display recent searches vs. search results (e.g., based on focus vs. Bloc state) required iteration.
    *   **Solution:** The final approach relies primarily on the `NewsSearchBloc`'s state to determine what to display (Initial -> Recent Searches, Loading -> Shimmer, Loaded -> Results/Empty, Error -> Error Message). The focus-based approach was attempted but led to potential timing issues between focus changes and Bloc state updates.
*   **Reliable Pagination:** Implementing infinite scrolling requires careful state management to prevent multiple simultaneous requests and handle end-of-list conditions.
    *   **Solution:** Used `ScrollController` listeners to detect reaching the bottom. Employed `bloc_concurrency` transformers (`droppable`) on the `LoadMoreNewsEvent` handler in the Bloc to prevent duplicate requests. The Bloc state (`hasReachedMax`) tracks if the end has been reached.
*   **API Key Security:** Storing the API key directly in code is insecure.
    *   **Solution:** Used `flutter_dotenv` to load the key from an untracked `.env` file at runtime.
*   **Consistent Error Handling:** Ensuring errors from different layers (network, parsing, caching) were handled gracefully.
    *   **Solution:** Mapped specific exceptions (`ServerException`, `NetworkException`, `CacheException`) to domain-level `Failure` types in the repository implementation. The UI layer then reacts to these `Failure` types via Bloc error states.

## Known Issues / Areas for Improvement

*   **`ClearSearchEvent` Not Handled:** The provided `NewsSearchBloc` **does not** have a handler for a `ClearSearchEvent`. The clear button in the `SearchScreen` currently only clears the text field and cannot reliably reset the Bloc state back to `NewsSearchInitial`. **Adding this event and handler to `NewsSearchBloc` is recommended** for proper clear functionality.
*   **State Field Dependencies:** The UI layer (specifically `SearchScreen` and `CategoryNewsList`) relies on specific field names within the Bloc states (e.g., `state.oldArticles`, `state.currentArticles`, `state.isFirstFetch`). If the Bloc state definitions change, the UI builder logic must be updated accordingly.
*   **Basic WebView:** The `WebViewArticle` implementation is basic. It could be enhanced with:
    *   More robust error handling and display (e.g., specific messages for network errors).
    *   A visible loading progress indicator.
    *   Navigation controls (back, forward, refresh) within the WebView screen's AppBar.
*   **Testing:** The project currently lacks automated tests (Unit, Widget, Integration). Adding tests would significantly improve reliability and maintainability.
*   **Offline Support:** No caching mechanism for articles is implemented. The app requires an internet connection to function.
*   **UI/UX Refinements:**
    *   Placeholder avatars are used; integrating real author avatars (if available) would be better.
    *   Error displays could be more user-friendly or context-specific.
    *   Could add pull-to-refresh on the search results screen.
*   **API Error Specificity:** Currently shows generic error messages. Could parse API error codes/messages to provide more specific feedback to the user.
*   **Accessibility:** No specific accessibility considerations (like semantic labels) have been explicitly added.

