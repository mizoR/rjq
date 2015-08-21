# rbq(1)
[![Gem Version](https://badge.fury.io/rb/rbq.svg)](http://badge.fury.io/rb/rbq)
[![Build Status](https://travis-ci.org/mizoR/rbq.svg)](https://travis-ci.org/mizoR/rbq)
[![Code Climate](https://codeclimate.com/github/mizoR/rbq/badges/gpa.svg)](https://codeclimate.com/github/mizoR/rbq)
[![Test Coverage](https://codeclimate.com/github/mizoR/rbq/badges/coverage.svg)](https://codeclimate.com/github/mizoR/rbq/coverage)
[![Dependency Status](https://gemnasium.com/mizoR/rbq.svg)](https://gemnasium.com/mizoR/rbq)

rbq is a command-line processor like [jq](http://stedolan.github.io/jq/). It is equipped with ruby-syntax.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rbq'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rbq

## Usage

### If you have the following JSON file:

```sh
$ cat <<JSON > languages.json
    [
        { "lang": "C",          "born_in": 1973, "inspired_by": ["Algol", "B"]                       },
        { "lang": "C++",        "born_in": 1980, "inspired_by": ["C", "Simula", "Algol"]             },
        { "lang": "C#",         "born_in": 2000, "inspired_by": ["Delphi", "Java", "C++", "Ruby"]    },
        { "lang": "Java",       "born_in": 1994, "inspired_by": ["C++", "Objective-C", "C#"]         },
        { "lang": "JavaScript", "born_in": 1995, "inspired_by": ["C", "Self", "awk", "Perl"]         },
        { "lang": "Perl",       "born_in": 1987, "inspired_by": ["C", "shell", "AWK", "sed", "LISP"] },
        { "lang": "PHP",        "born_in": 1995, "inspired_by": ["Perl", "C"]                        },
        { "lang": "Python",     "born_in": 1991, "inspired_by": ["ABC", "Perl", "Modula-3" ]         },
        { "lang": "Ruby",       "born_in": 1995, "inspired_by": ["Perl", "Smalltalk", "LISP", "CLU"] }
    ]
JSON
```

### Extract language's names of 4-characters, and dump as JSON

```sh
$ rbq 'select {|language| language["lang"].length == 4}.map {|language| language["lang"]}' languages.json
```

```json
[
  "Java",
  "Perl",
  "Ruby"
]
```

### Detect the youngest language, and dump as YAML

```sh
$ cat languages.json | rbq --to yaml 'max_by {|language| language["born_in"]}'
```

```yaml
---
lang: C#
born_in: 2000
inspired_by:
- Delphi
- Java
- C++
- Ruby
```

### Five languages which inspired many other languages, dump as CSV

```sh
$ rbq --to csv 'map {|language| language["inspired_by"]}.flatten.group_by(&:itself).map {|lang, langs| [lang, langs.count]}.sort_by(&:second).reverse[0..4]' < languages.json
```

```
Perl,4
C,4
C++,2
Algol,2
LISP,2
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/mizoR/rbq.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

