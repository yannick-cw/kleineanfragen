require 'test_helper'

class BadenWuerttembergLandtagScraperTest < ActiveSupport::TestCase
  def setup
    @scraper = BadenWuerttembergLandtagScraper
    @search_url = 'http://www.landtag-bw.de/cms/render/live/de/sites/LTBW/home/dokumente/die-initiativen/gesamtverzeichnis/contentBoxes/suche-initiative.html?'
    @legislative_page = Mechanize.new.get('file://' + Rails.root.join('test/fixtures/baden_wuerttemberg_legislative_term_page.html').to_s)
    @result_page = Nokogiri::HTML(File.read(Rails.root.join('test/fixtures/baden_wuerttemberg_result_page.html')))
  end

  test 'get legislative start and end date from url' do
    legislative = @scraper::Overview.new(15)
    actual = legislative.extract_legislative_dates(@legislative_page)
    expected = [Date.parse('01.05.2011'), Date.parse('30.04.2016')]
    assert_equal(expected, actual)
  end

  test 'get all months as array' do
    date1 = Date.parse('2014-01-01')
    date2 = Date.parse('2015-02-02')
    expected = [
      [2014, 1],
      [2014, 2],
      [2014, 3],
      [2014, 4],
      [2014, 5],
      [2014, 6],
      [2014, 7],
      [2014, 8],
      [2014, 9],
      [2014, 10],
      [2014, 11],
      [2014, 12],
      [2015, 1],
      [2015, 2]
    ]
    actual = @scraper::Overview.get_legislative_period(date1, date2)
    assert_equal(expected, actual)
  end

  test 'build single urls for legislative period' do
    types = ['KA']
    legislative_period = [
      [2013, 11],
      [2013, 12],
      [2014, 1],
      [2014, 2]
    ]
    actual = @scraper::Overview.get_search_urls(@search_url, legislative_period, types)
    expected = [
      @search_url + 'searchInitiativeType=KA&searchYear=2013&searchMonth=11',
      @search_url + 'searchInitiativeType=KA&searchYear=2013&searchMonth=12',
      @search_url + 'searchInitiativeType=KA&searchYear=2014&searchMonth=01',
      @search_url + 'searchInitiativeType=KA&searchYear=2014&searchMonth=02'
    ]
    assert_equal(expected, actual)
  end

  test 'extract result div from resultslist' do
    actual = @scraper.extract_result_divs(@result_page).size
    expected = 40
    assert_equal(expected, actual)
  end

  test 'extract full reference from result div' do
    div = @scraper.extract_result_divs(@result_page)[0]
    actual = @scraper.extract_full_reference(div)
    expected = '15/6432'
    assert_equal(expected, actual)
  end

  test 'extract reference from full reference' do
    full_reference = '15/6432'
    actual = @scraper.extract_reference(full_reference)
    expected = ['15', '6432']
    assert_equal(expected, actual)
  end

  test 'build detail url for answer-chek from full reference' do
    full_reference = '15/6432'
    actual = @scraper.build_answer_check_url(full_reference)
    expected = 'http://www.statistik-bw.de/OPAL/Ergebnis.asp?WP=15&DRSNR=6432'
    assert_equal(expected, actual)
  end
end