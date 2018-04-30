Please, put file **secret.rb** with content below to attributes folder

```ruby
default['scp_sitecore']['secrets'] = {
  'dev_sitecore_net_secret' => {
    'user' => '< e-mail >',
    'password' => '< password >',
  },
}
```
