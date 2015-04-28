require 'test_helper'

class SchleswigholsteinLandtagScraperOverviewTest < ActiveSupport::TestCase
  def setup
    @scraper = SchleswigHolsteinLandtagScraper
    @html = Nokogiri::HTML(
      File.read(
        Rails.root.join('test/fixtures/schleswigholstein_landtag_scraper_overview.html')
      ).force_encoding('WINDOWS-1252')
    )
    @table = @scraper.extract_table @html
    @blocks = @scraper.extract_blocks @table
  end

  test 'extract table from resultpage' do
    assert_equal 2679, @table.children.length
  end

  test 'get blocks from table' do
    @table = @scraper.extract_table @html
    assert_equal 1338, @blocks.length
  end

  test 'get title from block' do
    assert_equal 'Planungskapazitäten für den NOK und die Rader Hochbrücke', @scraper.extract_title(@blocks[15])
  end

  test 'is answered' do
    assert_equal false, @scraper.answer?(@blocks[1])
    assert_equal true, @scraper.answer?(@blocks[15])
    # not really answered, because date is missing.
    assert_equal true, @scraper.answer?(@blocks[0])
  end

  test 'get meta is nil if date is undefined' do
    assert_nil @scraper.extract_meta(@blocks[0])
  end

  test 'get ministries' do
    meta = @scraper.extract_meta(@blocks[15])
    assert_equal ['Minister/in für Wirtschaft, Arbeit, Verkehr und Technologie'], meta[:ministries]
  end

  test 'get originators' do
    meta = @scraper.extract_meta(@blocks[15])
    assert_equal ['Hans-Jörn Arp', 'Johannes Callsen'], meta[:originators][:people]
    assert_equal ['CDU'], meta[:originators][:parties]
  end

  test 'get date' do
    meta = @scraper.extract_meta(@blocks[15])
    assert_equal Date.parse('2214-12-14'), meta[:published_at]
  end

  test 'get full reference' do
    assert_equal '18/2537', @scraper.extract_full_reference(@blocks[15])
  end

  test 'get pdf url' do
    assert_equal 'http://www.landtag.ltsh.de/infothek/wahl18/drucks/2500/drucksache-18-2537.pdf', @scraper.extract_url(@blocks[15])
  end
end