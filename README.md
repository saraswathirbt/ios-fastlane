# ios-fastlane
A set of helper lanes to speedup the common tasks in iOS development at conichi.

## Why?
Because nobody wants to do boring work, let it be done by the machine 💻

## Installation
To install `fastlane` add to the `Gemfile` following line:
```ruby
gem 'fastlane'
```

## Usage
This `Fastfile` is supposed to be used inside another one. To import it add following action into the original `Fastfile`. You should put it inside `before_all`
```ruby
before_all do
  import_from_git(
    url: "git@github.com:conichiGMBH/ios-fastlane.git",
    branch: "HEAD",
    path: "fastlane/Fastfile"
  )
end
```

## Documentation
