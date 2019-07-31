# KingKonf

KingKonf gives you a way of declaratively specifying configuration variables for your application or library. It is focused on simplicity and being able to work well with environment variables, meaning that there is no nesting or fancy structures: all configuration can be passed as strings.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'king_konf'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install king_konf

## Usage

In order to specify a set configuration variables, simply subclass `KingKonf::Config` and use the DSL:

```ruby
require "king_konf"

class MyApplication::Config < KingKonf::Config
  # The prefix is used to identify environment variables. Here, we require
  # that all environment variables used for config start with `MY_APP_`,
  # followed by the all caps name of the variable.
  env_prefix :my_app

  # Strings are the simplest. This variable is required and *must* be set. By default,
  # a variable is optional.
  string :title, required: true

  # Integer variables require the value to be a valid integer:
  integer :score

  # Booleans by default use "true", "false", "1", and "0" as valid values:
  boolean :promoted

  # These can be configured:
  boolean :allow_comments, true_values: ["yes"], false_values: ["no"]

  # Lists are by default comma-separated arrays of strings:
  list :tags

  # You can separate with other characters, and decode each value as another type:
  list :codes, sep: ";", items: :integer

  # You can also provide a default value to any variable:
  string :body, default: "N/A"

  # You can restrict the set of allowed values:
  string :category, allowed_values: ["news", "stuff", "accouncements"]

  # You can provide a custom validation function:
  integer :even_number, validate_with: ->(int) { int % 2 == 0 }
end
```

Now that we've defined a configuration class, we can initialize it. KingKonf will read the ENV and detect any variables that match the prefix:

```ruby
# These would normally be passed by the system running your app:
ENV["MY_APP_TITLE"] = "Hello, World!"
ENV["MY_APP_SCORE"] = "85"
ENV["MY_APP_PROMOTED"] = "true"
ENV["MY_APP_ALLOW_COMMENTS"] = "no"
ENV["MY_APP_TAGS"] = "greetings,introductions,articles"
ENV["MY_APP_CODES"] = "435;2342;8678"

config = MyApplication::Config.new

# This validates that all required variables have been set, raising
# KingKonf::ConfigError if one is missing.
config.validate!

config.title #=> "Hello, World!"
config.score #=> 85
config.promoted #=> true
config.allow_comments #=> false
config.tags #=> ["greetings", "introductions", "articles"]
config.codes #=> [435, 2342, 8678]

# Boolean variables also get a nice query method alias:
config.promoted? #=> true
config.allow_comments? #=> false
```

If you prefer to use a config file, that's also possible. Simply load a YAML file with `#load_file`:

```ruby
config.load_file("config/my_app.yml")
```

A common pattern is to store config for all runtime environments in a single file and select the config based on the current environment, e.g.:

```ruby
config.load_file("config/my_app.yml", Rails.environment)
```

In that case, structure the config file like so:

```yaml
development:
  title: hello
  score: 25

test:
  title: yolo
  score: 13

production:
  title: yeah
  score: 99
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/dasch/king_konf.

## License

Copyright 2017 Daniel Schierbeck

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.

You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
