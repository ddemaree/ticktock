require 'test_helper'

class Event::ImporterTest < ActiveSupport::TestCase
  
  def setup
    Date.stubs(:today).returns Date.new(2008,2,15)
    Time.stubs(:now).returns Time.utc(2008,2,15,12,0,0)
    @account = Factory(:account)
  end
  
  context "A new Importer instance" do
    
    should "be initializable with an account" do
      assert_nothing_raised { importer = Event::Importer.new(@account) }
    end
    
    should "throw exception if argument is not account" do
      assert_raises ArgumentError do
        importer = Event::Importer.new(self)
      end
    end
    
    should "test import" do
      assert_nothing_raised do
        import_from_file_fixture
      end
      
      assert_equal 1, @last_import.length
      assert !@last_import.collect(&:import_token).include?(nil)
    end
    
    should "create new records on import" do      
      assert_difference "@account.events.count" do
        import_from_file_fixture
      end
    end
    
    should "not create duplicate records" do
      import_from_file_fixture
      
      assert_no_difference "@account.events.count" do
        import_from_file_fixture
      end
    end
    
  end
  
  def import_from_file_fixture
    @importer  = Event::Importer.new(@account)
    file_data = File.read(RAILS_ROOT + "/test/fixtures/csv_data.txt")
    @last_import = @importer.import(file_data)
  end
  
end