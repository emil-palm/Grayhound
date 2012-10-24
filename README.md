# Grayhound

A set of classes to interact with applde developer center.

# Contributions #
lacostej
https://github.com/lacostej/apple-dev
jerome.lacoste@gmail.com

He wrote apple-dev, which some parts of this code is written around.
I rewrote the inner workings of the ruby scripts and i felt like i couldnt with good conscience see this as a fork.

# Usage #
```ruby
require 'grayhound'
Grayhound::DeveloperCenter::setup_account "username","password", {:team_name => 'team'}
puts Grayhound::DeveloperCenter::profiles
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
