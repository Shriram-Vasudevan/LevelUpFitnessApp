fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios verify_setup

```sh
[bundle exec] fastlane ios verify_setup
```

Validate local config and ASC authentication

### ios beta

```sh
[bundle exec] fastlane ios beta
```

Build archive and upload to TestFlight

### ios upload_ipa

```sh
[bundle exec] fastlane ios upload_ipa
```

Upload an existing ipa to TestFlight (set IPA_PATH)

### ios submit_for_review

```sh
[bundle exec] fastlane ios submit_for_review
```

Submit latest processed TestFlight build to App Store review

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
