# The Cat Dex




- For demonstrative purposes it was chosen not to use any type of external dependencies except for TCA. All solutions work with standard library.
<br />
- Also for demonstrative purposes the project schemes were divided so each one of them can have its own apiKey, base URL and other configurations used through `EnvironmentUtil`:

| Environments
| -----------
| Debug
| Development
| Release
| Deploy

- For demonstrating offline storage the chosen favourites by the user are stored with `SwiftData`. In main cat breed list error handling for requests is used instead.