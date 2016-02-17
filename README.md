# ActiveRecordLite

This project is my own lite version of Rail's [ActiveRecord][ActiveRecord]. I did this project to better understand how ActiveRecord actually works: how ActiveRecord automates mapping between classes and tables, attributes and columns and implements object relational associations.

## Setup

I've created a minidatabase for testing.
1. First, head to the project directory in your terminal.
2.  `bundle install`
3. run the following command to initialize the sqlite3 database:
`cat pokemons.sql | sqlite3 pokemons.db`


## Lib Contents

Each file in `lib/` cooresponds to ActiveRecord functionality:
* `01_sql_object` is responsible for the `ActiveRecord::Base` logic
* `02_searchable` handles the packages SQL queries into bite-sized methods, such as `::where`
* `03_associatable` and `04_associatable2` handles the relationships between objects in different tables. Methods here include `belongs_to`, `has_many` and `has_one_through`

## Running RSpecs

ActiveRecordLite is test driven and has a complete test suite. Run the specs in the terminal with the command `bundle exec rspec`


Have fun poking around.

[stevendikowitz.com][stevendikowitz.com]



[ActiveRecord][https://github.com/rails/rails/tree/master/activerecord]
[stevendikowitz.com][http://stevendikowitz.com]
