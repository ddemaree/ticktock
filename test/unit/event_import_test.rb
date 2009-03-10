require 'test_helper'

class EventImportTest < ActiveSupport::TestCase

  should_belong_to :account
  should_validate_presence_of :account
  
  should "have attached file" do
    import = EventImport.new(:account => Factory(:account))
    
    assert !import.valid?
    assert_contains import.errors.full_messages, "Source must be set."
  end
  
  context "EventImport.mappable_fields" do
    setup { @mappable = EventImport.mappable_fields }
    
    should "have labels first" do
      assert_contains @mappable.collect(&:first), "Start time"
    end
    
    should "include no-import option" do
      assert_contains @mappable.collect(&:first), "Do not import"
    end
  end
  
  context "a saved EventImport instance" do
    setup { @event_import = Factory(:event_import) }
    
    should "return to_file" do
      assert @event_import.to_file
    end
    
    should "return number of rows" do
      assert_equal 2, @event_import.rows
    end
    
    should "return number of columns" do
      assert_equal 6, @event_import.columns
    end
    
    should "return parsed CSV array" do
      array = @event_import.from_csv
      assert array.is_a?(Array), array.class.to_s
      assert_equal 2, array.length
      assert_equal 6, array.first.length
    end
    
    should "not be importable without mapping" do
      assert !@event_import.can_import?
    end
    
    context "with ignore_first set to true" do
      setup { @event_import.ignore_first = true }
      
      should "suppress header row" do
        array = @event_import.from_csv
        assert_equal 1, array.length
      end
    end
    
    context "with invalid mapping" do
      setup do
        @event_import.mapping = ["","body","","stop","",""]
      end
      
      should "not be importable" do
        assert !@event_import.can_import?
      end
    end
    
    context "with good mapping" do
      setup do
        @event_import.ignore_first = true
        @event_import.mapping = ["","body","start","stop","","subject"]
      end
      
      should "be importable" do
        assert @event_import.can_import?
      end
      
      should "initialize Event objects" do
        events = @event_import.import
        assert_equal 1, events.length
        assert events.first.is_a?(Event)
      end
      
      should "initialize and save Events" do
        assert_difference "Event.count" do
          assert @event_import.import!
        end
      end
    end    
  end

end
