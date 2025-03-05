# The Cat Dex 😸

- For demonstrative purposes it was chosen not to use any type of external libraries or dependencies except for The Composable Architecure. That way the application is not dependent of external updates, which is a common trade-off to be evaluated for each dependency.

- For offline storage, the chosen favourites by the user are stored locally with `SwiftData`. In main cat breed list, error handling for api requests is used instead.

- Also for demonstrative purposes the project schemes were divided (Development, Release, Deploy, etc.) so each one of them can have its own value for apiKey, base URL and other configurations needed through `EnvironmentUtil`.