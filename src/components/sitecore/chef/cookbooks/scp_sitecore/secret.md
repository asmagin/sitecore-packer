Please, put file **secret.rb** with content below to attributes folder

``` ruby
default['scp_sitecore']['90xp'] = {
  'dev_sitecore_net_secret' => {
    'user' => '< e-mail >',
    'password' => '< password >',
  },
}
```