require 'test_helper'

class Event::ParamsTest < ActiveSupport::TestCase
  
  context "converting params to search string" do
    setup do
      @query_params = {
        :keywords => '"Yada yada" pork',
        :tagged   => "hello",
        :project  => "GWOD",
        :date_after => "yesterday"
      }
      
      @params = Event::Params.new(@query_params)
    end
    
    should "return in proper format" do
      assert_equal "\"Yada yada\" pork project:GWOD date_after:yesterday tagged:hello", @params.to_s
    end
    
    # should "be convertable back to params" do
    #   new_params = Event::Params.from_string(@params.to_s)
    #   assert_equal @query_params, new_params
    # end
  end
  
  context "When handling keyword params" do
    setup {
      @params = Event::Params.new({ :keywords => "Yada yada" })
    }
    
    should "respond to hash-like [] accessor" do
      assert_equal @params[:keywords], "Yada yada"
    end
    
    should "respond to accessor method" do
      assert_equal @params.keywords, "Yada yada"
    end
    
    should "return conditions" do
      assert_equal "(events.body LIKE '%Yada%' AND events.body LIKE '%yada%')", @params.to_conditions
    end
    
    context "containing multiple words" do
      setup { @params = Event::Params.new({ :keywords => '"Yada yada"' }) }
    
      should "return conditions" do
        assert_equal "(events.body LIKE '%Yada yada%')", @params.to_conditions
      end
    end
    
    context "containing multiple words and single words" do
      setup { @params = Event::Params.new({ :keywords => '"Yada yada" pork' }) }
      
      should "return conditions" do
        assert_equal "(events.body LIKE '%Yada yada%' AND events.body LIKE '%pork%')", @params.to_conditions
      end
    end
    
    context "excluding words" do
      setup { @params = Event::Params.new({ :not_keywords => 'beans' }) }
      
      should "return conditions" do
        assert_equal "(events.body NOT LIKE '%beans%')", @params.to_conditions
      end
    end
    
    context "excluding some words but including others" do
      setup { @params = Event::Params.new({ :not_keywords => 'beans', :keywords => 'pork' }) }
      
      should "return conditions" do
        assert_equal "(events.body NOT LIKE '%beans%') AND (events.body LIKE '%pork%')", @params.to_conditions
      end
    end
  end
  
  context "params containing :starred" do
    context "set to numeric value" do
      setup { @params = Event::Params.new({ :starred => "1" }) }

      should "return conditions where starred is true" do
        assert_equal "events.starred = 't'", @params.to_conditions
      end

      should "return conditions where starred is false" do
        @params.starred = "0"
        assert_equal "events.starred = 'f'", @params.to_conditions
      end
    end
    
    context "set to 'true' or 'false'" do
      setup { @params = Event::Params.new({ :starred => "true" }) }
      
      should "return conditions where starred is true" do
        assert_equal "events.starred = 't'", @params.to_conditions
      end
      
      should "return conditions where starred is false" do
        @params.starred = "false"
        assert_equal "events.starred = 'f'", @params.to_conditions
      end
    end
  end
  
  context "params containing :not_starred" do
    setup { @params = Event::Params.new({ :not_starred => "1" }) }
    
    should "return conditions where starred is false" do
      assert_equal "events.starred = 'f'", @params.to_conditions
    end
    
    should "return conditions where starred is true" do
      @params.not_starred = "0"
      assert_equal "events.starred = 't'", @params.to_conditions
    end
    
    should "not return duplicate conditions" do
      @params.starred = "0"
      assert_equal "events.starred = 'f'", @params.to_conditions
    end
  end
  
end