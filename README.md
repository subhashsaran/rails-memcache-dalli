
Let’s say that we have a Rails application with a popular page that loads slowly and whose performance we’d like to improve. One of the most effective ways to do this is to use caching. We’ve covered various caching techniques in the past but one thing we haven’t talked about is where the cache is stored. Rails’ cache store functionality is very modular. It uses the file system to store the cache by default but we can easily change this to store it elsewhere. Rails comes with several cache store options that we can choose from. The default used to be a memory store which stored the cache in local memory of that Rails process. This issue with this is that in production we often have multiple Rails instances running and each of these will have their own cache store which isn’t a good use of resources. The file store works well for smaller applications but isn’t very efficient as reading from and writing to the hard drive is relatively slow. If we use this for a cache that’s accessed frequently we’d be better off using something else.

This brings us to the memcache store which offers the best of both worlds. This is meant to be used with a Memcached server which means that the cache will be shared across multiple Rails instances or even separate servers. Access will be very fast as the data is stored in memory. This is a great option for serious caching but it’s best not to use the mem_cache_store that Rails includes. Instead we should use Dalli which is much improved and which has support for some additional features such as Memcached’s binary protocol. Note though that it needs at least version 1.4 of Memcached to use. In the upcoming Rails 4 release the built-in memcache store has been updated to use Dalli but in the meantime Dalli includes its own Rails cache store that we can use directly in Rails 3 applications.

Installing Memcached and Dalli

We have a Rails application with a cache store that we’ll switch to use Memcached and Dalli. The first step is to install Memcached, though if you’re running OS X it comes pre-installed. The easiest way to upgrade to a newer version is through Homebrew and we’ll do that now.

```

sudo apt-get update

sudo apt-get install memcached

```

Now that we have Memcached running we’ll set it up as the cache store for our application. We’ll add the dalli gem to the gemfile then run bundle to install it.

```
gem 'dalli'
```

Next we’ll modify the development config file and temporarily enable caching so that we can try it out. Ideally we’d set up a staging environment so that we could experiment with caching extensively on our local machine . We’ll also set the cache_store to dalli_store. If we were putting this app into production we’d need do the same in our production environment.


/config/development.rb

```
# Show full error reports and disable caching
config.consider_all_requests_local       = true
config.action_controller.perform_caching = true
config.cache_store = :dalli_store

```

Using Dalli

We can try this out in the console now. If we access Rails.cache we’ll see that it’s now an instance of DalliStore.


Rails console


```
>> Rails.cache
=> #<ActiveSupport::Cache::DalliStore:0x007fb05be840c8 @options={:compress=>nil}, @raise_errors=false, @data=#<Dalli::Client:0x007fb05be83f88 @servers="127.0.0.1:11211", @options={:compress=>nil}, @ring=nil>>

>> Rails.cache.write(:foo, 1)
=> true
>> Rails.cache.read(:foo)
=> 1

```
Instead of using read and write we can call fetch. This will attempt to read a value and if that fails, execute a block and set the cache to the result. If we run Rails.cache.fetch(:bar) { sleep 1; 2 } it will take a second to run as that value doesn’t exist in the cache and so the code in the block will be run. If we run it again it will return the stored value instantly.

There’s another useful method called read_multi. This will attempt to access all the values for each of the keys passed in and return a hash.


Requires Ruby 1.9.2 or higher.


### Commands used in this episode

```
memcached -h | head -1
brew install memcached
/usr/local/bin/memcached
ssh deployer@198.58.98.181
sudo apt-get install memcached
vim /etc/memcached.conf
```


### Commands used in this console

```
Rails.cache
Rails.cache.write(:foo, 1)
Rails.cache.read(:foo)
Rails.cache.fetch(:bar) { sleep 1; 2 }
Rails.cache.multi_read(:foo, :bar)
Rails.cache.stats
y _
Rails.cache.write(:foo, 1, expires_in: 5.seconds)
```
