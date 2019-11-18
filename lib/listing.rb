require 'pg'

class Listing

  attr_reader :name, :description, :price, :available_date

  def initialize(name:, description:, price:, available_date:)
    @name = name
    @description = description
    @price = price
    @available_date = available_date
end

  def self.all
    if ENV['RACK'] == 'test'
      connect = PG.connect(dbname: 'aircouch_test')
    else
      connect = PG.connect(dbname: 'aircouch')
    end
    result = connect.exec('SELECT * FROM listings;')
    result.map { |listing| Listing.new(name: listing['name'], description: listing['description'], price: listing['price'], available_date: listing['available_date']) }
  end

  def self.create(name:, description:, price:, available_date: )
    if ENV['RACK'] == 'test'
      connect = PG.connect(dbname: 'aircouch_test')
    else
      connect = PG.connect(dbname: 'aircouch')
    end
    result = connect.exec("INSERT INTO listings(name, description, price, available_date) VALUES('#{name}', '#{description}', #{price}, '#{available_date}') RETURNING name, description, price, available_date;")
    Listing.new(name: result[0]['name'], description: result[0]['description'], price: result[0]['price'], available_date: result[0]['available_date'])
  end
end
