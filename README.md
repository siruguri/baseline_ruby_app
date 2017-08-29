# baseline_ruby_app

The way this works is, you add methods to `App::App`, and you can run `ruby app.rb m1,m2,m3` where each m1, m2 etc is a method name

The point is that you get a simple app that uses ActiveRecord to access a db. For example, try `ruby app.rb -c hello` (aka, `ruby app.rb --commands hello`)

You configure the db in `config/database.yml`
