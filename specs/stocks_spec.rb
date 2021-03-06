require('minitest/autorun')
require('minitest/rg')
require_relative('../models/stocks')
require_relative('../models/albums')
require_relative('../models/artists')
require_relative('../db/sql_runner')

class TestStocks < Minitest::Test
  def setup
    # Need to setup some artists that the Albums can use.
    # The Artist class should be tested first to make sure this code works.
    Artist.destroy()
    @artist1 = Artist.new( { "name" => "The Beatles", "genre" => "popular" })
    @artist1.save
    @artist2 = Artist.new( { "name" => "Muddy Waters", "genre" => "blues" })
    @artist2.save

    # Need to setup some albums that the Stock table can use.
    # The Album class should be tested prior to this to make sure this code will work.
    Album.destroy()
    @album1 = Album.new( { "name" => "Abbey Road", "artist_id" => @artist1.id } )
    @album1.save
    @album2 = Album.new( { "name" => "The Beatles", "artist_id" => @artist1.id } )
    @album2.save
    @album3 = Album.new( { "name" => "Electric Mud", "artist_id" => @artist2.id } )
    @album3.save

    # Create stock for the stock tests. Relying on destroy and save working

    Stock.destroy()
    @stock1 = Stock.new( { 'album_id' => @album1.id, 'format' => 'CD', 'stock_level' => 5, 'threshold' => 5, 'buy_price' => 5.00, 'sell_price' => 7.50 } )
    @stock1.save
    @stock2 = Stock.new( { 'album_id' => @album1.id, 'format' => 'LP', 'stock_level' => 4, 'threshold' => 3, 'buy_price' => 7.00, 'sell_price' => 15.00 } )
    @stock2.save
    @stock3 = Stock.new( { 'album_id' => @album2.id, 'format' => 'CD', 'stock_level' => 3, 'threshold' => 5, 'buy_price' => 5.00, 'sell_price' => 10.00 } )
    @stock3.save
    @stock4 = Stock.new( { 'album_id' => @album3.id, 'format' => 'CD', 'stock_level' => 1, 'threshold' => 2, 'buy_price' => 7.00, 'sell_price' => 10.00 } )
  end

  def test_01_stock_initalize
    # Make sure that all the fields can be read
    assert_equal(@album3.id, @stock4.album_id)
    assert_equal('CD', @stock4.format)
    assert_equal(1, @stock4.stock_level)
    assert_equal(2, @stock4.threshold)
    assert_equal(7.00, @stock4.buy_price)
    assert_equal(10.00, @stock4.sell_price)
    assert_equal(0, @stock4.id)
  end

  def test_02_stock_save
    assert_equal(true, @stock1.id > 0)
  end

  def test_03_stock_retrieve
    assert_equal(3, Stock.all.count)
  end

  def test_04_stock_update
    # Test that all fields can be updated (except id)
    stock = Stock.all.last
    stock.album_id = @stock4.album_id
    stock.format = @stock4.format
    stock.stock_level = @stock4.stock_level
    stock.threshold = @stock4.threshold
    stock.buy_price = @stock4.buy_price
    stock.sell_price = @stock4.sell_price
    id = stock.id
    stock.update
    stock = Stock.all.last
    assert_equal(id, stock.id)  # Got the right entry back
    assert_equal(@stock4.album_id, stock.album_id)
    assert_equal(@stock4.format, stock.format)
    assert_equal(@stock4.stock_level, stock.stock_level)
    assert_equal(@stock4.threshold, stock.threshold)
    assert_equal(@stock4.buy_price, stock.buy_price)
    assert_equal(@stock4.sell_price, stock.sell_price)
  end

  def test_05_stock_retrieve_by_id
    id = @stock3.id
    assert_equal(id, Stock.by_id(id).id)
  end

  def test_09_stock_destroy
    @stock1.delete
    @stock2.delete
    @stock3.delete
    assert_equal( 0, Stock.all.count)
  end

  # # Extensions to standard CRUD

  def test_06_stock_by_album
    stocks = Stock.by_album( @album1.id )
    assert_equal(2, stocks.count)
    assert_equal(@album1.id, stocks.first.album_id)
  end

  def test_07_stock_by_artist
    # Requires a join with the album table
    stocks = Stock.by_artist( @artist1.id )
    assert_equal(3, stocks.count)
    assert_equal(@artist1.id, Album.by_id(stocks.first.album_id).artist_id )
  end

  def test_08_format_by_artist
    formats = Stock.formats_by_artist( @artist1.id )
    assert_equal(2, formats.count)
    assert_equal("CD", formats[0])
    assert_equal("LP", formats[1])
  end

  def test_09_stock_by_artist_and_format
    stocks = Stock.by_artist( @artist1.id, 'LP' )
    assert_equal(1, stocks.count)
    assert_equal("Abbey Road", Album.by_id(stocks.first.album_id).name )
  end

  def test_10_stock_needing_attention
    stocks = Stock.attention_needed()
    assert_equal(2, stocks.count)
  end

  def test_11_stock_exists
    assert_equal(true, Stock.exists?(@stock1))
    @stock3.format = "LP"
    assert_equal(false, Stock.exists?(@stock3))
  end

end