trimodel
========
A rails helper gem that makes life easier when you have to handle relationships between three models. It has its own generator in order to simplify things as much as possbible.

It will generate the needed migrations between the three given models, create their associations is a separate file (keeps your code clean) and run the migrations as well. 

In case you change your mind it will rollback everything without leaving any trash in your app. 


Setup
=====
To install in your ruby installation, type:

```ruby
  gem install trimodel
```

For Rails projects, add the following line in your Gemfile,
inside the :development group of gems:

```ruby
  group :development do
    gem 'trimodel'
  end
```

Type 

```ruby 
  rails g
```

in your terminal and you should see the gem's generators

```ruby
  Trimodel:
    trimodel:delete
    trimodel:new
```

Use
===
The gem contains two generators that create and delete the 
associations, the migrations and the join tables between 
the three given models. 

For example for the models Car, Assembly and Part and wanting to
find all Parts used in a Car or all Cars that use a specific 
Part with the Assembly as the intermediate model, type:

```ruby
  trimodel:new --models Car Assembly Part
```

<b>Note:</b> The order you type the models is important.


And in your code you get all the Parts by typing

```ruby
  car = Car.where(:id => 1)
  car.parts # => [Part, Part, ...] 

  part = Part.where(:id => 100)
  part.cars # => [Car, Car, ...]
```


Remove an association
=====================
Simply use the delete generator with the models you want to
remove the association from.

```ruby
  trimodel:delete --models Car Assembly Part
```

